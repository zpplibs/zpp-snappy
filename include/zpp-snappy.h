#pragma once

#include <zpp.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Returns 0 for success
/// 1 for append failure
/// 2 for operation failure
uint8_t zpp_snappy(
    bool compress,
    const char* data, size_t data_len,
    void* list_ptr
);

#ifdef __cplusplus
}
#endif