#include <stdio.h>

int sum(int a, int b) { return a + b; }
int mul(int a, int b) { return a * b; }

int main(void) {
    int a, b;
    if (scanf("%d %d", &a, &b) != 2) return 1;
    printf("sum = %d\n", sum(a, b));
    printf("mul = %d\n", mul(a, b));
    return 0;
}
