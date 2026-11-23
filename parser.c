#include <stdio.h>
#include <stdlib.h>
#include "parser.h"

struct Atomo *atomoActual = NULL; /* Nodo actual */
char c = '$';                      /* Átomo actual */
static int erroresSintacticos = 0;
static FILE *outFile = NULL;

/* Avanza al siguiente nodo de la lista ligada;
 '$' para fin de cadena ⊣ */
void avanzar(void) {
    if (atomoActual != NULL) {
        atomoActual = atomoActual->next;
    }
    c = (atomoActual != NULL) ? atomoActual->atomo : '$';
}

/* error sintáctico con línea/columna y avanza hasta un delimitador seguro */
void errorSintactico(const char *esperado) {
    erroresSintacticos++;
    if (atomoActual != NULL) {
        printf("[Error Sintactico] Linea %d, Columna %d: se esperaba %s, pero se encontro '%c'\n",
               atomoActual->num_linea,
               atomoActual->num_col,
               esperado, c);
        if (outFile) {
            fprintf(outFile, "[Error Sintactico] Linea %d, Columna %d: se esperaba %s, pero se encontro '%c'\n",
                    atomoActual->num_linea,
                    atomoActual->num_col,
                    esperado, c);
        }
    } else {
        printf("[Error Sintactico] Fin de archivo inesperado: se esperaba %s\n", esperado);
        if (outFile) {
            fprintf(outFile, "[Error Sintactico] Fin de archivo inesperado: se esperaba %s\n", esperado);
        }
    }
    /* Recuperación hasta un delimitador de sentencia o bloque para continuar */
    while (c != '$' && c != ';' && c != '#' && c != '}' && c != ')') {
        avanzar();
    }
    if (c == ';') {
        avanzar();
    }
}

/* Verifica y consume el átomo terminal esperado */
void consumir(char esperado) {
    if (c == esperado) {
        avanzar();
    } else {
        char msg[16];
        sprintf(msg, "'%c'", esperado);
        errorSintactico(msg);
    }
}

/* manda llamar desde el main() del .lex */
void iniciarAnalisisSintactico(struct Atomo *inicioLista, FILE *archivoSalida) {
    outFile = archivoSalida;
    erroresSintacticos = 0;
    atomoActual = inicioLista;
    c = (atomoActual != NULL) ? atomoActual->atomo : '$';

    printf("\n-------------- ANALISIS SINTACTICO --------------\n");
    if (outFile) fprintf(outFile, "\n-------------- ANALISIS SINTACTICO --------------\n");

    Program();

    if (c != '$') {
        errorSintactico("fin de archivo ('$')");
    }

    if (erroresSintacticos == 0) {
        printf("\n[RESULTADO] Analisis sintactico correcto: el programa fuente es VALIDO.\n");
        if (outFile) fprintf(outFile, "\n[RESULTADO] Analisis sintactico correcto: el programa fuente es VALIDO.\n");
    } else {
        printf("\n[RESULTADO] Se encontraron %d error(es) sintactico(s).\n", erroresSintacticos);
        if (outFile) fprintf(outFile, "\n[RESULTADO] Se encontraron %d error(es) sintactico(s).\n", erroresSintacticos);
    }
}

/* ========================================================================== */
/* REGLAS 1 A 22: PROGRAMA, FUNCIONES Y DECLARACIONES                         */

/* 1: <Program> -> <Func><otraFunc>   c.s.(1) = { f, i, g } */
void Program(void) {
    if (c == 'f' || c == 'i' || c == 'g') {
        Func();
        otraFunc();
        return;
    } else {
        errorSintactico("declaracion de funcion ('f', 'i' o 'g')");
    }
}

/* 2: <otraFunc> -> <Func><otraFunc>  c.s.(2) = { f, i, g }
   3: <otraFunc> -> xi                c.s.(3) = { $ } */
void otraFunc(void) {
    if (c == 'f' || c == 'i' || c == 'g') {
        struct Atomo *posAntes = atomoActual;
        Func();
        otraFunc();
        if (atomoActual == posAntes) avanzar();
        return;
    } else if (c == '$') {
        return;
    } else {
        errorSintactico("otra funcion ('f', 'i', 'g') o fin de archivo");
    }
}

/* 4: <Func> -> <TipoF> a ( <listArg> ) { <Cuerpo> }   c.s.(4) = { f, i, g } */
void Func(void) {
    if (c == 'f' || c == 'i' || c == 'g') {
        TipoF();
        consumir('a');
        consumir('(');
        listArg();
        consumir(')');
        consumir('{');
        Cuerpo();
        consumir('}');
        return;
    } else {
        errorSintactico("tipo de funcion ('f', 'i' o 'g')");
    }
}

/* 5: <TipoF> -> <Tipo>   c.s.(5) = { f, i }
   6: <TipoF> -> g        c.s.(6) = { g } */
void TipoF(void) {
    if (c == 'f' || c == 'i') {
        Tipo();
        return;
    } else if (c == 'g') {
        avanzar();
        return;
    } else {
        errorSintactico("tipo de retorno ('f', 'i' o 'g')");
    }
}

/* 7: <listArg> -> <Tipo> a <otroArg>   c.s.(7) = { f, i }
   8: <listArg> -> xi                   c.s.(8) = { ) } */
void listArg(void) {
    if (c == 'f' || c == 'i') {
        Tipo();
        consumir('a');
        otroArg();
        return;
    } else if (c == ')') {
        return;
    } else {
        errorSintactico("argumento ('f', 'i') o ')'");
    }
}

/* 9:  <otroArg> -> , <Tipo> a <otroArg>   c.s.(9)  = { , }
   10: <otroArg> -> xi                     c.s.(10) = { ) } */
void otroArg(void) {
    if (c == ',') {
        struct Atomo *posAntes = atomoActual;
        avanzar();
        Tipo();
        consumir('a');
        otroArg();
        if (atomoActual == posAntes) avanzar();
        return;
    } else if (c == ')') {
        return;
    } else {
        errorSintactico("',' o ')'");
    }
}

/* 11: <Cuerpo> -> <listDecl><listaS>
       c.s.(11) = { f, i, a, u, t, b, q, z, s, p, [, } } */
void Cuerpo(void) {
    if (c == 'f' || c == 'i' || c == 'a' || c == 'u' || c == 't' ||
        c == 'b' || c == 'q' || c == 'z' || c == 's' || c == 'p' ||
        c == '[' || c == '}') {
        listDecl();
        listaS();
        return;
    } else {
        errorSintactico("declaracion, sentencia o '}'");
    }
}

/* 13: <listDecl> -> <Decl><listDecl>   c.s.(13) = { f, i }
   12: <listDecl> -> xi                 c.s.(12) = { a, u, t, b, q, z, s, p, [, } } */
void listDecl(void) {
    if (c == 'f' || c == 'i') {
        struct Atomo *posAntes = atomoActual;
        Decl();
        listDecl();
        if (atomoActual == posAntes) avanzar();
        return;
    } else if (c == 'a' || c == 'u' || c == 't' || c == 'b' || c == 'q' ||
               c == 'z' || c == 's' || c == 'p' || c == '[' || c == '}') {
        return;
    } else {
        errorSintactico("declaracion ('f', 'i'), sentencia o '}'");
    }
}

/* 14: <Decl> -> <Tipo> a <valorIni> <listaVar> ;   c.s.(14) = { f, i } */
void Decl(void) {
    if (c == 'f' || c == 'i') {
        Tipo();
        consumir('a');
        valorIni();
        listaVar();
        consumir(';');
        return;
    } else {
        errorSintactico("tipo de dato ('f' o 'i')");
    }
}

/* 15: <Tipo> -> f   c.s.(15) = { f }
   16: <Tipo> -> i   c.s.(16) = { i } */
void Tipo(void) {
    if (c == 'f') {
        avanzar();
        return;
    } else if (c == 'i') {
        avanzar();
        return;
    } else {
        errorSintactico("'f' o 'i'");
    }
}

/* 17: <valorIni> -> = <tipoVal>   c.s.(17) = { = }
   18: <valorIni> -> xi            c.s.(18) = { , ; } */
void valorIni(void) {
    if (c == '=') {
        avanzar();
        tipoVal();
        return;
    } else if (c == ',' || c == ';') {
        return;
    } else {
        errorSintactico("'=', ',' o ';'");
    }
}

/* 19: <listaVar> -> , a <valorIni> <listaVar>   c.s.(19) = { , }
   20: <listaVar> -> xi                          c.s.(20) = { ; } */
void listaVar(void) {
    if (c == ',') {
        struct Atomo *posAntes = atomoActual;
        avanzar();
        consumir('a');
        valorIni();
        listaVar();
        if (atomoActual == posAntes) avanzar();
        return;
    } else if (c == ';') {
        return;
    } else {
        errorSintactico("',' o ';'");
    }
}

/* 21: <tipoVal> -> n   c.s.(21) = { n }
   22: <tipoVal> -> v   c.s.(22) = { v } */
void tipoVal(void) {
    if (c == 'n') {
        avanzar();
        return;
    } else if (c == 'v') {
        avanzar();
        return;
    } else {
        errorSintactico("constante entera ('n') o cadena ('v')");
    }
}

/* ========================================================================== */
/* SENTENCIAS Y ESTRUCTURAS DE CONTROL              */

/* 50..58: <Sent> -> <Asig> | Q | <Ret> | <Trocar> | <Enq> | <Faz> | <Se> | <Para> | <Llama> */
void Sent(void) {
    if (c == 'a')      { Asig();   return; } /* c.s.(50) = { a } */
    else if (c == 'u') { Q();      return; } /* c.s.(51) = { u } */
    else if (c == 't') { Ret();    return; } /* c.s.(52) = { t } */
    else if (c == 'b') { Trocar(); return; } /* c.s.(53) = { b } */
    else if (c == 'q') { Enq();    return; } /* c.s.(54) = { q } */
    else if (c == 'z') { Faz();    return; } /* c.s.(55) = { z } */
    else if (c == 's') { Se();     return; } /* c.s.(56) = { s } */
    else if (c == 'p') { Para();   return; } /* c.s.(57) = { p } */
    else if (c == '[') { Llama();  return; } /* c.s.(58) = { [ } */
    else {
        errorSintactico("inicio de sentencia valido");
    }
}

/* 59: <listaS> -> <Sent><listaS>   c.s.(59) = { a, u, t, b, q, z, s, p, [ }
   60: <listaS> -> xi               c.s.(60) = { #, } } */
void listaS(void) {
    if (c == 'a' || c == 'u' || c == 't' || c == 'b' || c == 'q' ||
        c == 'z' || c == 's' || c == 'p' || c == '[') {
        struct Atomo *posAntes = atomoActual;
        Sent();
        listaS();
        if (atomoActual == posAntes) avanzar();
        return;
    } else if (c == '#' || c == '}') {
        return;
    } else {
        errorSintactico("sentencia, '#' o '}'");
    }
}

/* 69: <Enq> -> q ( <expLogica> ) # <listaS> #   c.s.(69) = { q } */
void Enq(void) {
    if (c == 'q') {
        avanzar();
        consumir('(');
        expLogica();
        consumir(')');
        consumir('#');
        listaS();
        consumir('#');
        return;
    } else {
        errorSintactico("'q' (enquanto)");
    }
}

/* 70: <Se> -> s ( <expLogica> ) # <listaS> #   c.s.(70) = { s } */
void Se(void) {
    if (c == 's') {
        avanzar();
        consumir('(');
        expLogica();
        consumir(')');
        consumir('#');
        listaS();
        consumir('#');
        return;
    } else {
        errorSintactico("'s' (se)");
    }
}

/* 71: Q -> u ;   c.s.(71) = { u } */
void Q(void) {
    if (c == 'u') {
        avanzar();
        consumir(';');
        return;
    } else {
        errorSintactico("'u' (quebrar)");
    }
}

/* 72: <Faz> -> z # <listaS> # q ( <expLogica> ) ;   c.s.(72) = { z } */
void Faz(void) {
    if (c == 'z') {
        avanzar();
        consumir('#');
        listaS();
        consumir('#');
        consumir('q');
        consumir('(');
        expLogica();
        consumir(')');
        consumir(';');
        return;
    } else {
        errorSintactico("'z' (fazer)");
    }
}

/* 73: <Ret> -> t <valRet> ;   c.s.(73) = { t } */
void Ret(void) {
    if (c == 't') {
        avanzar();
        valRet();
        consumir(';');
        return;
    } else {
        errorSintactico("'t' (retorno)");
    }
}

/* 74: <valRet> -> E            c.s.(74) = { (, a, n, [ }
   75: <valRet> -> {<expCad>}   c.s.(75) = { { }
   76: <valRet> -> xi           c.s.(76) = { ; } */
void valRet(void) {
    if (c == '(' || c == 'a' || c == 'n' || c == '[') {
        E();
        return;
    } else if (c == '{') {
        avanzar();
        expCad();
        consumir('}');
        return;
    } else if (c == ';') {
        return;
    } else {
        errorSintactico("expresion, '{' o ';'");
    }
}

/* 82: <Para> -> p a [ n , n ] # <listaS> #   c.s.(82) = { p } */
void Para(void) {
    if (c == 'p') {
        avanzar();
        consumir('a');
        consumir('[');
        consumir('n');
        consumir(',');
        consumir('n');
        consumir(']');
        consumir('#');
        listaS();
        consumir('#');
        return;
    } else {
        errorSintactico("'p' (para)");
    }
}

/* 83: <Trocar> -> b ( a ) : # c ( n ) { <listaS> } <casos> #   c.s.(83) = { b } */
void Trocar(void) {
    if (c == 'b') {
        avanzar();
        consumir('(');
        consumir('a');
        consumir(')');
        consumir(':');
        consumir('#');
        consumir('c');
        consumir('(');
        consumir('n');
        consumir(')');
        consumir('{');
        listaS();
        consumir('}');
        casos();
        consumir('#');
        return;
    } else {
        errorSintactico("'b' (trocar)");
    }
}

/* 85: <casos> -> c ( n ) { <listaS> } <casos>   c.s.(85) = { c }
   86: <casos> -> ( ) { <listaS> } <casos>       c.s.(86) = { ( }
   84: <casos> -> xi                             c.s.(84) = { # } */
void casos(void) {
    if (c == 'c') {
        struct Atomo *posAntes = atomoActual;
        avanzar();
        consumir('(');
        consumir('n');
        consumir(')');
        consumir('{');
        listaS();
        consumir('}');
        casos();
        if (atomoActual == posAntes) avanzar();
        return;
    } else if (c == '(') {
        struct Atomo *posAntes = atomoActual;
        avanzar();
        consumir(')');
        consumir('{');
        listaS();
        consumir('}');
        casos();
        if (atomoActual == posAntes) avanzar();
        return;
    } else if (c == '#') {
        return;
    } else {
        errorSintactico("'c' (caso), '(' (default) o '#'");
    }
}





/* -------------------------------------------------------------------------- */
/* Regla 23: <Asig> -> a <opArit> E ; */
void Asig(){
	/* El átomo "a" representa un identificador */
		if (c == 'a'){
			consumir('a'); /* Se "consume" el identificador */
			opArit(); /* Reglas de la 24 a 29: operadores de asignación */
			E(); /* Regla 30: expresión aritmética */
            consumir(';');  /* La asignación debe terminar con punto y coma entonces: */

		} else {
			/* Aqui se recopilan los errores sintacticos */
			errorSintactico("identificador 'a' para iniciar <Asig>");
		}
}

/* Reglas de 24 a 29: <opArit> -> | x | y | k | r | o */
void opArit() {
	char s = c;
	/* Listado de atomos para hacer comparaciones */
	if (s == '=' || s == 'x' || s == 'y' || s == 'k' || s == 'r' || s == 'o'){
		} else {
			errorSintactico("operador de asignación");
		}	
}

/* Regla 30: E -> T E' */
void E() {
	T();
	EP();
}

/* Regla 31: E' -> + T E' | - T E' | ε */
void EP() {
	char s = c;
	if (s == '+'){
		T();
		EP(); /* Recursión para cadenas como "a + b + c " */
	} else if (s == '-') {
		T();
		EP();
	}
	/* Si no es un símbolo '+' ni un símbolo '-' se aplica la de E' -> ε (no se hace nada) */
}

/* Regla 34: T -> F T' */
void T() {
	F();
	TP(); /* Cola del término multiplicación, división y módulo */
}

/* Reglas de la 35 a la 38: T' -> * F T' | / F T' | % F T' | ε */
void TP() {
	char s = c;
	
	if(s == '*') {
		F();
		TP();
        return;
	} else if (s == '/') {
		F();
		TP();
        return;
	} else if(s == '%') {
		F();
		TP();
        return;
	}
	/* Si no es una multiplicación, división o módulo se aplica epsilon */
}

/* Reglas de 39 a 42: F -> ( E ) | a | n | <llama> */
void F() {
	char s = c;
    
    if (s == '(') {
        /* Producción F -> ( E ) */
		E();
        consumir(')');
    } else if (s == 'a') {
        consumir('a');
    }else if (s == 'n') {
        consumir('n');
    } else if (s == '[') {
		/* Producción F -> <Llama> (first de Llama o sea '[') */
		Llama();
	} else {
		errorSintactico("'(', 'a', 'n' o '['");
	}
}

/* Regla 43: R -> E <opRel> E */
void R(){
	E(); /* Expresion aritmética por la izquierda */
	opRel();
	E(); /* Expresion aritmética por la derecha */
}

/* Regla 44 a la regla 49: <opRel> -> > | < | e | d | m | w */
void opRel(){
	char s = c;
	if (s == '>' || s == '<' || s == 'e' || s == 'd' || s == 'm' || s == 'w') {
        return;
    } else {
        errorSintactico("un operador relacional (>, <, ==, !=, >=, <=)");
    }
}

/* Reglas 61 y 62: <expLogica> -> ! <expRel> | R <expLog> */
void expLogica() {
    char s = c;

    if (s == '!') {
        /* Producción expLogica -> ! <expRel> */
        expRel();
    } else {
        /* Producción expLogica -> R <expLog> */
        R();
        expLog();
    }
}

/* Reglas 63 y 64: <expLog> -> <opLog> R | ε */
void expLog() {
    char s = c;
    if (s == 'h' || s == 'j') {
        opLog();
        R();
    }
    /* Si no cae en ninguno de los casos no se hace nada */
}

/* Reglas 65 y 66: <expRel> -> { R } | E */
void expRel() {
	char s = c;
    if (s == '{') {
        /* Producción expRel -> { R } */
        R();
        consumir('}');

    } else {
        /* Producción expRel -> E */
        E();
    }
}

/* Reglas 67 y 68: <opLog> -> h | j */
void opLog() {
    char s = c;

    if (s == 'h' || s == 'j') {
        return;
    } else {
        errorSintactico("un operador lógico (&& o ||)");
    }
}

/* Reglas 77 y 78: <expCad> -> a <opCad> | v <opCad> */
void expCad(){
	char s = c;
	 /* 'a' = identificador, 'v' = constante cadena */
    if (s == 'a' || s == 'v') {
        opCad();
    } else {
        errorSintactico("Se esperaba un identificador 'a' o una cadena 'v'");
    }
} 

/* Reglas 79 a 81:  <opCad> -> l <expCad> | h <expCad> | ε */
void opCad() {
	char s = c;
    /* 'l' = like, 'h' = & */
	if (s == 'l' || s == 'h') {
		expCad();
	}
}

/* Regla 87: <Llama> -> [ a ( <listP> ) ] */
void Llama() {
    if (c == '[') {

        if (c == 'a') {

            if (c == '(') {

                listP();   /* Lista de parámetros */

                if (c == ')') {

                    if (c == ']') {
                    } else {
                        errorSintactico("']' para cerrar la llamada");
                    }
                } else {
                    errorSintactico("')' en la llamada a función");
                }
            } else {
                errorSintactico("'(' en la llamada a función");
            }
        } else {
            errorSintactico("un identificador 'a' en la llamada");
        }
    } else {
        errorSintactico("'[' para iniciar una llamada a función");
    }
}

/* Reglas 88 a la regla 90: <listP> -> ε | E <Param> | { <expCad> } <Param> */
void listP() {
    char s = c;

    /* First(E) = { '(', 'a', 'n', '[' } */
    if (s == '(' || s == 'a' || s == 'n' || s == '[') {
        E();
        Param();
    }
    /* First({ <expCad> }) = { '{' } */
    else if (s == '{') {
        expCad();

        if (c == '}') {
        } else {
            errorSintactico("'}' en el parámetro de cadena");
        }
        Param();
    }
    /* Si no coincide con ninguno, aplicamos listP -> ξ (lista vacía) */
}

/* Reglas 91 a 92: <Param> -> , <listP> | ε */
void Param() {
    if (c == ',') {
        listP();
    }
    /* Si no hay coma se aplica la regla Param -> ξ (fin de parámetros) */
}
