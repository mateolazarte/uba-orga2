#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {
    uint32_t res = 0; 

    if(string == NULL){
        return res;

    }else{
        while(*string != '\0'){
            res++;
            string++;
    }
        return res;
    }
}


uint32_t contar_espacios(char* string) {
    int32_t res = 0;
    uint32_t l = longitud_de_string(string); 
    uint32_t i = 0;
    while(i < l ){
        if(*string == ' '){
            res++;
        }
        string++;
        i++;
    }
    return res;
}
    

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));
}

*/
