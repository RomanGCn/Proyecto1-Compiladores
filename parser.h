#ifndef PARSER_H
#define PARSER_H

#include <stdio.h>

struct Atomo {
    char atomo;
    int num_linea;
    int num_col;
    struct Atomo *next;
};

/* Átomo actual y puntero global */
extern struct Atomo *atomoActual;
extern char c;

/* Funciones base del parser */
void iniciarAnalisisSintactico(struct Atomo *inicioLista, FILE *archivoSalida);
void avanzar(void);
void consumir(char esperado);
void errorSintactico(const char *esperado);

/* (Estructura, Declaraciones y Sentencias)  */
void Program(void);
void otraFunc(void);
void Func(void);
void TipoF(void);
void listArg(void);
void otroArg(void);
void Cuerpo(void);
void listDecl(void);
void Decl(void);
void Tipo(void);
void valorIni(void);
void listaVar(void);
void tipoVal(void);
void Sent(void);
void listaS(void);
void Enq(void);
void Se(void);
void Q(void);
void Faz(void);
void Ret(void);
void valRet(void);
void Para(void);
void Trocar(void);
void casos(void);

/* (Expresiones y Llamadas)  */
void Asig(void);
void opArit(void);
void E(void);
void EP(void);
void T(void);
void TP(void);
void F(void);
void R(void);
void opRel(void);
void expLogica(void);
void expLog(void);
void expRel(void);
void opLog(void);
void expCad(void);
void opCad(void);
void Llama(void);
void listP(void);
void Param(void);

#endif
