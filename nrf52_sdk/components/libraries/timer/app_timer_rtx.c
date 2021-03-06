#include "app_timer.h"
#include <stdlib.h>
#include "nrf.h"
#include "nrf_soc.h"
#include "app_error.h"
#include "app_util.h"
#include "cmsis_os.h"

#define MAX_RTC_COUNTER_VAL 0x00FFFFFF /**< Maximum value of the RTC counter. */

/**@brief This structure keeps information about osTimer.*/
typedef struct
{
    void       * argument;
    osTimerDef_t timerDef;
    uint32_t     buffer[5];
    osTimerId    id;
}app_timer_info_t;

/**@brief Store an array of timers with configuration. */
typedef struct
{
    uint8_t            max_timers; /**< The maximum number of timers*/
    uint32_t           prescaler;
    app_timer_info_t * app_timers; /**< Pointer to table of timers*/
}app_timer_control_t;
app_timer_control_t app_timer_control;

/**@brief This structure is defined by RTX. It keeps information about created osTimers. It is used in app_timer_start(). */
typedef struct os_timer_cb_
{
    struct os_timer_cb_ * next;
    uint8_t               state;
    uint8_t               type;
    uint16_t              reserved;
    uint16_t              tcnt;
    uint16_t              icnt;
    void                * arg;
    const osTimerDef_t  * timer;
} os_timer_cb;

/**@brief This functions are defined by RTX.*/
extern osStatus svcTimerStop(osTimerId timer_id);                        /**< Used in app_timer_stop(). */

extern osStatus svcTimerStart(osTimerId timer_id, uint32_t millisec);    /**< Used in app_timer_start(). */

static void * rt_id2obj(void *id)                                         /**< Used in app_timer_start(). This function gives information if osTimerID is valid */
{

    if ((uint32_t)id & 3)
        return NULL;

#ifdef OS_SECTIONS_LINK_INFO

    if ((os_section_id$$Base != 0) && (os_section_id$$Limit != 0))
    {
        if (id < (void *)os_section_id$$Base)
            return NULL;

        if (id >= (void *)os_section_id$$Limit)
            return NULL;
    }
#endif

    return id;
}


uint32_t app_timer_init(uint32_t                      prescaler,
                        uint8_t                       max_timers,
                        uint8_t                       op_queues_size,
                        void                        * p_buffer,
                        app_timer_evt_schedule_func_t evt_schedule_func)
{
    if (p_buffer == NULL)
    {
        return NRF_ERROR_INVALID_PARAM;
    }

    app_timer_control.prescaler  = prescaler;
    app_timer_control.max_timers = max_timers;
    app_timer_control.app_timers = p_buffer;

    // Initialize buffer for timer
    for (int i = 0; i < max_timers; i++)
    {
        app_timer_control.app_timers[i].timerDef.timer = app_timer_control.app_timers[i].buffer;
        app_timer_control.app_timers[i].id             = 0;
    }
    return NRF_SUCCESS;
}


uint32_t app_timer_create(app_timer_id_t            * p_timer_id,
                          app_timer_mode_t            mode,
                          app_timer_timeout_handler_t timeout_handler)
{

    if ((timeout_handler == NULL) || (p_timer_id == NULL))
    {
        return NRF_ERROR_INVALID_PARAM;
    }

    // Find free timer
    for (int i = 0; i < app_timer_control.max_timers; i++)
    {
        if (!app_timer_control.app_timers[i].id)
        {
            app_timer_control.app_timers[i].timerDef.ptimer = (os_ptimer)timeout_handler;
            app_timer_control.app_timers[i].id              =
                osTimerCreate((const osTimerDef_t *)&(app_timer_control.app_timers[i].timerDef),
                              (os_timer_type)mode, NULL);
            *p_timer_id = (app_timer_id_t) app_timer_control.app_timers[i].id;

            if (p_timer_id)
                return NRF_SUCCESS;
            else
            {
                app_timer_control.app_timers[i].id = 0;
                return NRF_ERROR_INVALID_PARAM; // This error is unspecified by rtx
            }

        }
    }
    return NRF_ERROR_NO_MEM;
}


uint32_t app_timer_start(app_timer_id_t timer_id, uint32_t timeout_ticks, void * p_context)
{
    if ((timeout_ticks < APP_TIMER_MIN_TIMEOUT_TICKS))
    {
        return NRF_ERROR_INVALID_PARAM;
    }
    uint32_t timeout_ms =
        ((uint32_t)ROUNDED_DIV(timeout_ticks * 1000 * (app_timer_control.prescaler + 1),
                               (uint32_t)APP_TIMER_CLOCK_FREQ));

    if (rt_id2obj((void *)timer_id) == NULL)
        return NRF_ERROR_INVALID_PARAM;

    // Pass p_context to timer_timeout_handler
    ((os_timer_cb *)(timer_id))->arg = p_context;

    // osTimerStart() returns osErrorISR if it is called in interrupt routine.
    switch (osTimerStart((osTimerId)timer_id, timeout_ms) )
    {
        case osOK:
            return NRF_SUCCESS;

        case osErrorISR:
            break;

        case osErrorParameter:
            return NRF_ERROR_INVALID_PARAM;

        default:
            return NRF_ERROR_INVALID_PARAM;
    }

    // Start timer without svcCall
    switch (svcTimerStart((osTimerId)timer_id, timeout_ms))
    {
        case osOK:
            return NRF_SUCCESS;

        case osErrorISR:
            return NRF_ERROR_INVALID_STATE;

        case osErrorParameter:
            return NRF_ERROR_INVALID_PARAM;

        default:
            return NRF_ERROR_INVALID_PARAM;
    }
}


uint32_t app_timer_stop(app_timer_id_t timer_id)
{
    switch (osTimerStop((osTimerId)timer_id) )
    {
        case osOK:
            return NRF_SUCCESS;

        case osErrorISR:
            break;

        case osErrorParameter:
            return NRF_ERROR_INVALID_PARAM;

        case osErrorResource:
            return NRF_SUCCESS;

        default:
            return NRF_ERROR_INVALID_PARAM;
    }

    // Stop timer without svcCall
    switch (svcTimerStop((osTimerId)timer_id))
    {
        case osOK:
            return NRF_SUCCESS;

        case osErrorISR:
            return NRF_ERROR_INVALID_STATE;

        case osErrorParameter:
            return NRF_ERROR_INVALID_PARAM;

        case osErrorResource:
            return NRF_SUCCESS;

        default:
            return NRF_ERROR_INVALID_PARAM;
    }
}


uint32_t app_timer_stop_all(void)
{
    for (int i = 0; i < app_timer_control.max_timers; i++)
    {
        if (app_timer_control.app_timers[i].id)
        {
            (void)app_timer_stop((app_timer_id_t)app_timer_control.app_timers[i].id);
        }
    }
    return 0;
}


extern uint32_t os_tick_val(void);
uint32_t app_timer_cnt_get(uint32_t * p_ticks)
{
    *p_ticks = os_tick_val();
    return NRF_SUCCESS;
}


uint32_t app_timer_cnt_diff_compute(uint32_t   ticks_to,
                                    uint32_t   ticks_from,
                                    uint32_t * p_ticks_diff)
{
    *p_ticks_diff = ((ticks_to - ticks_from) & MAX_RTC_COUNTER_VAL);
    return NRF_SUCCESS;
}


