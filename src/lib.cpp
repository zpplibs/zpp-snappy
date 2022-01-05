#include <zpp-snappy.h>
#include <snappy.h>

extern "C" {

/// Returns 0 for success
/// 1 for append failure
/// 2 for operation failure
uint8_t zpp_snappy(
    bool compress,
    const char* data, size_t data_len,
    void* list_ptr
) {
    uint8_t ret;
    std::string out;
    if (compress) {
        ret = 0 < snappy::Compress(data, data_len, &out) ? 0 : 2;
    } else {
        ret = snappy::Uncompress(data, data_len, &out) ? 0 : 2;
    }
    if (ret == 0) {
        ret = zpp_array_list_u8_append(list_ptr, out.data(), out.size()) ? 0 : 1;
    }
    return ret;
}

/// Returns 0 on failure
size_t zpp_snappy_get_uncompressed_len(
    const char* data, size_t data_len
) {
    size_t result;
    return snappy::GetUncompressedLength(data, data_len, &result) ? result : 0;
}

} // "C"