#include <stdint.h>
#include <stdio.h>

__attribute__((noinline)) int census_subject(uint64_t value) {
    volatile uint64_t copy = value;
    return copy == 1;
}
__attribute__((noinline)) int caller_first(uint64_t value) {
    return census_subject(value);
}
__attribute__((noinline)) int caller_second(uint64_t value) {
    return census_subject(value);
}
int main(void) {
    setbuf(stdout, NULL);
    int command;
    while ((command = getchar()) != EOF) {
        if (command == 'A') {
            int sum = caller_first(1) + caller_first(1) + caller_first(0)
                    + caller_second(0) + caller_second(0);
            printf("A:%d\n", sum);
        } else if (command == 'B') {
            int sum = caller_first(0) + caller_first(0) + caller_first(1)
                    + caller_second(1) + caller_second(1) + caller_second(0);
            printf("B:%d\n", sum);
        } else if (command == 'Q') {
            return 0;
        }
    }
    return 0;
}
