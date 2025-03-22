#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    vector_t* nuevo = malloc(sizeof(vector_t));
    nuevo->size = 0;
    nuevo->capacity = 2;
    nuevo->array = malloc(2 * sizeof(uint32_t));
    return nuevo;
}

uint64_t get_size(vector_t* vector) {
    return vector->size;
}

void push_back(vector_t* vector, uint32_t elemento) {
    //Si se intenta agregar un elemento al vector que ya ocupó toda su capacidad, se la debe duplicar
    //antes de pushear.
    if(vector->size == vector->capacity){
        vector->capacity *= 2;
        //"realloc" toma el puntero al espacio de memoria que ya había asigando "malloc" y lo expande.
        vector->array = realloc(vector->array, vector->capacity * sizeof(uint32_t));
    } 
    vector->array[vector->size] = elemento;
    vector->size++;
}

int son_iguales(vector_t* v1, vector_t* v2) {
    if(v1->size != v2->size){
        return 0;
    }
    for(uint32_t i = 0; i < v1->size; i++){
        if(v1->array[i] != v2->array[i]){
            return 0;
        }
    }
    return 1;
}

uint32_t iesimo(vector_t* vector, size_t index) {
    if(index >= vector->size){
        return 0;
    }
    return vector->array[index];
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out){
    uint32_t elem = vector->array[index];
    *out = elem; //en la posicion de memoria apuntada por "out" guardo "elem"
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
    if(longitud_del_array == 0){
        return NULL;
    }
    vector_t* res = *array_de_vectores;
    uint64_t mayor = (*array_de_vectores)->size;
    for(uint32_t i = 1; i < longitud_del_array; i++){
        array_de_vectores++;
        if((*array_de_vectores)->size > mayor){
            res = *array_de_vectores;
            mayor = (*array_de_vectores)->size;
        }
    }
    return res;
}
