#include <stdint.h>

inline constexpr static uint32_t hash_fnv1a32_const(const char* string) noexcept
{
    uint32_t hash = 0x811c9dc5;
    const uint32_t prime = 0x1000193;
    while (*string)
    {
        hash = hash ^ (uint32_t)(*string++);
        hash = hash * prime;
    }
    return hash;
}

// quick and incomplete for now
#define HASH(name) hash_fnv1a32_const(name)
#define CONST_HASH(name) hash_fnv1a32_const(name)