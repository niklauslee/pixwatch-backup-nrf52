
#include "ble.h"
#include "ble_pixwatch_c.h"
#include "ble_gattc.h"
#include "device_manager.h"
#include "ble_db_discovery.h"
#include "app_trace.h"

#define LOG          app_trace_log            /**< Debug logger macro that will be used in this file to do logging of important information over UART. */


static ble_pixwatch_c_t * mp_ble_pixwatch; /**< Pointer to the current instance of the PixWatch Client module. The memory for this provided by the application.*/


/**@brief 128-bit service UUID for the PixWatch Service.
 */
const ble_uuid128_t ble_pixwatch_base_uuid128 =
{
    {
    	// FBA21525-4C50-4FCC-8BB4-20768A0787DB
        0xDB, 0x87, 0x07, 0x8A, 0x76, 0x20, 0xB4, 0x8B,
        0xCC, 0x4F, 0x50, 0x4C, 0x15, 0x25, 0xA2, 0xFB
    }
};

/**@brief 128-bit current local time UUID.
 */
const ble_uuid128_t ble_pixwatch_local_time_base_uuid128 =
{
    {
        // FBA21530-4C50-4FCC-8BB4-20768A0787DB
        0xDB, 0x87, 0x07, 0x8A, 0x76, 0x20, 0xB4, 0x8B,
        0xCC, 0x4F, 0x50, 0x4C, 0x15, 0x30, 0xA2, 0xFB
    }
};


static void db_discover_evt_handler(ble_db_discovery_evt_t * p_evt)
{
    LOG("[PixWatch]: Database Discovery handler called with event 0x%x\r\n", p_evt->evt_type);

    ble_pixwatch_c_evt_t evt;

    // Check if the PixWatch Service was discovered.
    if (p_evt->evt_type == BLE_DB_DISCOVERY_COMPLETE &&
        p_evt->params.discovered_db.srv_uuid.uuid == PIXWATCH_UUID_SERVICE &&
        p_evt->params.discovered_db.srv_uuid.type == BLE_UUID_TYPE_VENDOR_BEGIN)
    {
        mp_ble_pixwatch->conn_handle = p_evt->conn_handle;

        // Find the handles of the Current Local Time characteristic.
        uint32_t i;

        for (i = 0; i < p_evt->params.discovered_db.char_count; i++)
        {
        	switch (p_evt->params.discovered_db.charateristics[i].characteristic.uuid.uuid)
        	{
        		case PIXWATCH_UUID_CHAR_LOCAL_TIME:
                    // Found Local Time characteristic. Store CCCD and value handle and break.
                    mp_ble_pixwatch->cccd_handle =
                        p_evt->params.discovered_db.charateristics[i].cccd_handle;
                    mp_ble_pixwatch->local_time_handle =
                        p_evt->params.discovered_db.charateristics[i].characteristic.handle_value;
                    break;

        		default:
        			break;
        	}
        }

        LOG("[PixWatch]: PixWatch Service discovered at peer.\r\n");

        evt.evt_type = BLE_PIXWATCH_C_EVT_DISCOVERY_COMPLETE;

        mp_ble_pixwatch->evt_handler(mp_ble_pixwatch, &evt);
    }
    else
    {
        evt.evt_type = BLE_PIXWATCH_C_EVT_SERVICE_NOT_FOUND;
        mp_ble_pixwatch->evt_handler(mp_ble_pixwatch, &evt);
    }

}


uint32_t ble_pixwatch_c_init(ble_pixwatch_c_t * p_pixwatch, const ble_pixwatch_c_init_t * p_pixwatch_init)
{
    if (   (p_pixwatch_init == NULL)
        || (p_pixwatch_init->error_handler == NULL)
        || (p_pixwatch_init->evt_handler == NULL)
        || (p_pixwatch == NULL))
    {
        return NRF_ERROR_NULL;
    }

    mp_ble_pixwatch = p_pixwatch;

    p_pixwatch->evt_handler      = p_pixwatch_init->evt_handler;
    p_pixwatch->error_handler    = p_pixwatch_init->error_handler;
    p_pixwatch->conn_handle      = BLE_CONN_HANDLE_INVALID;
    p_pixwatch->local_time_handle = BLE_GATT_HANDLE_INVALID;

    ble_uuid_t pixwatch_uuid;
    pixwatch_uuid.uuid = PIXWATCH_UUID_SERVICE;
    pixwatch_uuid.type = BLE_UUID_TYPE_VENDOR_BEGIN;

    return ble_db_discovery_evt_register(&pixwatch_uuid, db_discover_evt_handler);
}


static void on_disconnect(ble_pixwatch_c_t * p_pixwatch, ble_evt_t const * p_ble_evt)
{
    // The connection handle is now invalid. It will be re-initialized upon connection.
    p_pixwatch->conn_handle = BLE_CONN_HANDLE_INVALID;

    if (p_pixwatch->local_time_handle != BLE_GATT_HANDLE_INVALID)
    {
        // There was a valid instance on the peer. Send an event to the
        // application, so that it can do any clean up related to this module.
        ble_pixwatch_c_evt_t evt;

        evt.evt_type = BLE_PIXWATCH_C_EVT_DISCONN_COMPLETE;

        p_pixwatch->evt_handler(p_pixwatch, &evt);
        p_pixwatch->local_time_handle = BLE_GATT_HANDLE_INVALID;
    }
}


static void local_time_read(ble_pixwatch_c_t * p_pixwatch, const ble_evt_t * p_ble_evt)
{
    ble_pixwatch_c_evt_t evt;
    // uint32_t err_code = NRF_SUCCESS;

    if (p_ble_evt->evt.gattc_evt.gatt_status == BLE_GATT_STATUS_SUCCESS)
    {
    	const uint8_t  * p_data = p_ble_evt->evt.gattc_evt.params.read_rsp.data;
    	// const uint32_t length   = p_ble_evt->evt.gattc_evt.params.read_rsp.len;
    	uint32_t localtime = p_data[0] | (p_data[1] << 8) | (p_data[2] << 16) | (p_data[3] << 24);

    	evt.local_time = localtime;
        evt.evt_type = BLE_PIXWATCH_C_EVT_LOCAL_TIME;
        p_pixwatch->evt_handler(p_pixwatch, &evt);
    }
}

void ble_pixwatch_c_on_ble_evt(ble_pixwatch_c_t * p_pixwatch, ble_evt_t const * p_ble_evt)
{
    LOG("[PixWatch]: BLE event handler called with event 0x%x\r\n", p_ble_evt->header.evt_id);

    switch (p_ble_evt->header.evt_id)
    {
        case BLE_GAP_EVT_CONNECTED:
            p_pixwatch->conn_handle = p_ble_evt->evt.gap_evt.conn_handle;
            break;

        case BLE_GATTC_EVT_READ_RSP:
            local_time_read(p_pixwatch, p_ble_evt);
            break;

        case BLE_GAP_EVT_DISCONNECTED:
            on_disconnect(p_pixwatch, p_ble_evt);
            break;

        default:
            // No implementation needed.
            break;
    }
}


uint32_t ble_pixwatch_c_local_time_read(ble_pixwatch_c_t const * p_pixwatch)
{
    if (p_pixwatch->local_time_handle == BLE_GATT_HANDLE_INVALID)
    {
        return NRF_ERROR_NOT_FOUND;
    }

    return sd_ble_gattc_read(p_pixwatch->conn_handle, p_pixwatch->local_time_handle, 0);
}
