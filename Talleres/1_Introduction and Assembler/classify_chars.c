#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void classify_chars_in_string(char* string, char** vowels_and_cons) {
    *vowels_and_cons = calloc(64, sizeof(char)); //vocales
    *(vowels_and_cons + 1) = calloc(64, sizeof(char)); //consonantes
    char* vocales = *vowels_and_cons;
    char* consonantes = *(vowels_and_cons + 1);
    while(*string != '\0'){
        if(*string == 'a' || *string == 'e' || *string == 'i' || *string == 'o' || *string == 'u'){
            *vocales = *string;
            vocales++;
        } else {
            *consonantes = *string;
            consonantes++;
        }
        string++;
    }
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
    for(uint64_t i = 0; i < size_of_array; i++){
        array->vowels_and_consonants = malloc(2 * sizeof(char*));
        classify_chars_in_string(array->string, array->vowels_and_consonants);
        array++;
    }
}
