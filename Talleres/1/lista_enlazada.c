#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
    lista_t* newList = malloc(sizeof(lista_t));
    newList->head = NULL;
    return newList;
}

uint32_t longitud(lista_t* lista) {
    nodo_t* it;
    it = lista->head;
    uint32_t res = 0;
    while (it != NULL)
    {
        res++;
        it = it->next;
    }
    return res;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
    nodo_t *nuevo = malloc(sizeof(uint32_t*)*2 + sizeof(uint64_t)); 

    uint32_t* newArreglo = calloc(longitud,sizeof(uint32_t));

    for(uint64_t i = 0; i < longitud; i++){
        newArreglo[i] = arreglo[i];
    }

    nuevo->arreglo = newArreglo;
    nuevo->longitud = longitud;
    nuevo->next = NULL;
    if(lista->head == NULL){
        lista->head = nuevo;
        return;
    }
    nodo_t* it;
    it = lista->head;
    while (it->next != NULL)
    {
        it = it->next;
    }
    it->next = nuevo;
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
    uint32_t j = 0; 
    nodo_t* it;
    it = lista->head;
    while (j < i){
        it = it->next;
        j++;
    }
    return it;
    
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
    nodo_t* it;
    it =  lista->head;
    uint64_t res = 0;
    while(it != NULL){
        res+= it->longitud;
        it = it->next;
    }
    return res;
}

void imprimir_lista(lista_t* lista) {
    nodo_t* it;
    it =  lista->head;
    while(it != NULL){
        printf("|| %ld || ->", it->longitud);
        it = it->next;
    }
    printf("|| NULL ||");

}

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {
    uint64_t i = 0;
    int found = 1;
    int not_found = 0;
    while(i < size_of_array){
        if(array[i] == elemento_a_buscar){
            return found;
        }
        i++;
    }
    return not_found;

}

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
    nodo_t* it;
    int found = 1;
    int not_found = 0;
    it =  lista->head;
    while(it != NULL){
        if( found == array_contiene_elemento(it->arreglo, it->longitud, elemento_a_buscar)){
            return found;
        }
        it = it->next;
    }
    return not_found;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
    nodo_t* it;
    it =  lista->head;
    while (it != NULL){
        nodo_t* aux;
        aux = it->next;
        free((uint32_t*)it->arreglo);
        it->arreglo = NULL;
        free(it);
        it = aux;
    }
    free(lista);
}