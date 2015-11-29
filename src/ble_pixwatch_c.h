
#ifndef BLE_PIXWATCH_C_H__
#define BLE_PIXWATCH_C_H__

#include "ble_gattc.h"
#include "ble.h"
#include "ble_srv_common.h"
#include "device_manager.h"

/* PixWatch Service UUID */
#define PIXWATCH_UUID_SERVICE          0x1525  /**< 16-bit service UUID for PixWatch Service */
#define PIXWATCH_UUID_CHAR_LOCAL_TIME  0x1530  /**< 16-bit local time UUID */


/**@brief PixWatch Service UUIDs */
extern const ble_uuid128_t ble_pixwatch_base_uuid128;             /**< Service UUID. */
extern const ble_uuid128_t ble_pixwatch_local_time_base_uuid128;  /**< Local Time UUID. */


/**@brief Event types that are passed from client to application on an event. */
typedef enum
{
    BLE_PIXWATCH_C_EVT_SERVICE_NOT_FOUND,  /**< The PixWatch Service was not found at the peer. */
    BLE_PIXWATCH_C_EVT_DISCOVERY_COMPLETE, /**< The PixWatch Service was found at the peer. */
    BLE_PIXWATCH_C_EVT_DISCONN_COMPLETE,   /**< */
    BLE_PIXWATCH_C_EVT_LOCAL_TIME          /**< A new local time reading has been received. */
} ble_pixwatch_c_evt_type_t;

// Forward declaration of the ble_pixwatch_c_t type.
typedef struct ble_pixwatch_c_s ble_pixwatch_c_t;

/**@brief PixWatch client event. */
typedef struct
{
    ble_pixwatch_c_evt_type_t evt_type; /**< Type of event. */
    uint32_t                  local_time;
} ble_pixwatch_c_evt_t;


/**@brief PixWatch Service client event handler type. */
typedef void (* ble_pixwatch_c_evt_handler_t) (ble_pixwatch_c_t * p_cts, ble_pixwatch_c_evt_t * p_evt);

struct ble_pixwatch_c_s
{
    ble_pixwatch_c_evt_handler_t evt_handler;       /**< Event handler to be called for handling events from the PixWatch Service client. */
    ble_srv_error_handler_t      error_handler;     /**< Function to be called if an error occurs. */
    uint16_t                     local_time_handle; /**< Handle of Local Time Characteristic at the peer (handles are provided by the BLE stack through the DB Discovery module). */
    uint16_t                     cccd_handle;       /**< Handle of the CCCD of the Current Local Time Characteristic at the peer. */
    uint16_t                     conn_handle;       /**< Handle of the current connection. BLE_CONN_HANDLE_INVALID if not in a connection. */
};

/**@brief Current Time Service client init structure. This structure contains all options and data needed for initialization of the client.*/
typedef struct
{
    ble_pixwatch_c_evt_handler_t evt_handler;   /**< Event handler to be called for handling events from the PixWatch Service client. */
    ble_srv_error_handler_t      error_handler; /**< Function to be called if an error occurs. */
} ble_pixwatch_c_init_t;


/**@brief Function for initializing the PixWatch Service client.
 *
 */
uint32_t ble_pixwatch_c_init(ble_pixwatch_c_t * p_pixwatch, const ble_pixwatch_c_init_t * p_pixwatch_init);

/**@brief Function for handling the application's BLE stack events.
 *
 */
void ble_pixwatch_c_on_ble_evt(ble_pixwatch_c_t * p_pixwatch, const ble_evt_t * p_ble_evt);

/**@brief Function for reading the peer's Current Time Service Current Time Characteristic.
 *
 */
uint32_t ble_pixwatch_c_local_time_read(ble_pixwatch_c_t const * p_pixwatch);



#endif /* BLE_PIXWATCH_C_H__ */
