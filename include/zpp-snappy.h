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

/// Returns 0 on failure
size_t zpp_snappy_get_uncompressed_len(
    const char* data, size_t data_len
);

#ifdef __cplusplus
}
#endif