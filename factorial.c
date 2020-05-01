int factorial(int n);

int main()
{
    // R2 = 1   # Aux para salto condicional.
    // R0 = 10  # n
    printf("Factorial: %d\n", factorial(10));   // Goto FACTORIAL
    // MAIN:
    // Goto MAIN
    return 0;
}

// FACTORIAL:
// # Se necesita una copia de; R0 en memoria RAM por cada recursividad. 
int factorial(int n)
{
    int result; // R1

    if (n <= 1) // if(R2 < R0) goto ELSE-1
        result = 1; // R1 = 1
        // goto ELSE-2
    else    // ELSE-1:
        // Mem[DStack + R3] = R3 * 1    # 1: porque solo se guardara un dato por cada recursividad.
        // Mem[R3 * 1 + 0] = R0         # 0: porque se almacena el primer dato a respaldar por la recursividad.
        // Stack++;  R3 = R3 + 1;
        // R0 = R0 - 1
        // Goto FACTORIAL
        // CONTINUE:
        // Stack--;  R3 = R3 - 1;
        // R4 = Mem[R3 * 1 + 0]     # Tmp del R0 pasado
        // R1 = R1 * R4
        result = n * factorial(n - 1);
    //ELSE-2:
    return result;
    // R5 = 0
    // if(R3 != R5) goto CONTINUE
    // Goto MAIN
}

