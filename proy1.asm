.Model small
.Stack
.Data
    Msg db "El archivo a leer se llama: ","$" ;Se pide el archivo a leer
    fichero db "arc.txt$"
    ;fichero db 10 dup (?); se almacena en "fichero" el nombre del archivo
    Cadena db 100 dup(?) ;Para la cadena a leer
    SL db 10,13,"$"    ;Salto de Linea
    Handle dw 0
    NumNom dw 0
    usr db "Usuario: $" ;Cadena Usuario
    ctr db "Contrasena: $" ;Cadena contrasena
    Usuario db 50 dup (?), "$"
    Contra db 30 dup (?), "$"
    IndiceArr1 dw 0 ;Indice del arreglo para el usuario 
    IndiceArr2 dw 0 ;Indice del arreglo para la contra
    NumCiclo dw 0 ;Es la variable que cuenta en que parte del programa va
    ContApPat dw 0 ;Para contar las primeras 2 letras del apellido paterno para la contrasena
    ContApMat dw 0 ;Para contar las primeras 2 letras del apellido materno para la contrasena
    NumCP dw 0 ;Para contar el numero del CP en el que va, los CP tienen 5 numeros 
    NumDir dw 0

.Code
    Main proc
    Mov Dx, @Data
    Mov Ds, Dx
    
    ;Parte del c?digo que imprime el mensaje inicial
    Mov Ah, 09h ;Funci?n 09h de la Int21h para imprimir
    Mov Dx, offset Msg; se lee hasta el final de "Msg"
    Int 21h; Se llama a la Int 21h
    
    ;Pedir el nombre del archivo (funcion 3FH)
    ;Mov Ah, 3fh ;Se lee de dispositivo en este caso
    ;Mov Bx, 00; El handle se inicializa en 00
    ;Mov Cx, 11 ;Se le pasa al registro Cx el numero de bytes a leer
    ;Mov Dx, offset fichero ;Se mueve hasta el final de fichero
    ;Int 21h
    ;mov bx,ax
    ;mov ah,3eh  ;Cerramos el archivo
    ;int 21h 
    
    ;Abrir fichero (funcion 3DH)
    Mov Ah, 3dh ;Instruccion para abrir el fichero
    Mov Al, 000b ;Decimos que queremos que sea de solo lectura
    Mov Dx, offset fichero ;Pasamos el nombre del archivo al registro Dx para que sepa que buscar
    Int 21h ;Llama a la interrupcion 21h
    Mov Bx, Ax ;Mover lo resultante al manejador (Handle)
    
    ;Leer fichero (Funci?n 3FH Int21h)
    Mov Ah, 3fh ;Instruccion de lectura de ficheros
    Mov Handle, Bx ;Pasamos lo que tenemos en Bx a Handle
    Mov Cx, 100 ;Numero de bytes a leer
    Mov Dx, offset Cadena ;Se almacena en la variable Cadena
    Int 21h
 
    
    ;Cerrar Fichero
    Mov Ah, 3eh ;Instruccion para cerrar archivo
    Int 21h
    
    ;Imprimir cadena
    Mov Ah, 09h ;Intruccion para imprimir
    Mov Dx, offset fichero ;Se va a imprimir la cadena
    Int 21h 
    
    ;Imprimir un salto de linea
    Mov Ah, 09h 
    Mov Dx, offset SL
    Int 21h
    
    ;Ahora tengo que separar la cadena segun vengan saliendo los / 
    ;Leer caracter por caracter con un ciclo e ir guardando lo que se lea
    ;en un arreglo de caracteres hasta llegar a un separador (en el caso de
    ;ser el ultimo valor buscar un terminador $)
    ;Se debe leer la cadena asi: "Nombres/ApPaterno/ApMaterno/CP/Direccion/Carrera$
    
    ;Imprimir "Usuario: "
    
    
    ;Para el ciclo de nombres, se pide imprimir la inicial de cada nombre
    ;para esto lo que se hace es imprimir el primer caracter y cada uno despues
    ;de un espacio, excepto si este es un separador "/" y en ese caso
    ;se avanza a otro ciclo
    
    ;Se guarda el valor de el primer caracter en el 

    Mov Di, IndiceArr1 ;Se mueve el valor (0) de IndiceArr al registro Di

    Mov Cl, Cadena[Si]
    Mov Usuario[Di], Cl ;Se agrega al string de usuario
    Mov Contra[Di], Cl ;Se agrega al string de contrasena
    
    
    BuscarEsp:
        Mov Si, NumNom ;Movemos el valor de NumNom al registro Si
        Cmp Cadena[Si], "/" ;Buscamos un separador
        Je ApPat ;Se mueve a la etiqueta que resetea guarda el Apellido paterno y sus primeras 2 letras
        Cmp Cadena[Si], " " ;Buscamos un espacio, para imprimir el sig caracter
        Je ImpNoms ;Brinca a la etiqueta para buscar si el sig caracter es un separador
        Inc NumNom ;Incrementamos el valor de NumNom para que siga buscando
        Loop BuscarEsp ;Se sigue buscando un espacio
        
    ImpNoms: ;Ciclo que guarda en la variable InicialesNom las iniciales de los nombres
        Inc NumNom ;Se incrementa el valor de la variable NumNom
        Mov Si, NumNom ;Se pasa al registro Si el valor de NumNom
        
        Inc IndiceArr1 ;Se incrementa el valor de IndiceArr
        Inc IndiceArr2 ;Se incrementa el valor del indice del arreglo para la cont
        Mov Di, IndiceArr1 ;Se mueve al registro Di el valor de IndiceArr
        
        Cmp Cadena[Si], "/" ;Se busca un separador, en casa de encontrarlo se termina
        Je ApPat ;Se termina el pedo
        
        ;Mov Ah, 02 ;Se mueve a Ah el valor 02 para decirle que queremos usar la funcion 02 de la INT 21h
        ;Mov Dl, Cadena[Si] ;Se mueve al registro Dl el caracter que se quiere imprimir
        ;Int 21h ;Se manda a llamar a la interrupcion 21h
        
        Mov Cl, Cadena[Si] ;Se mueve el caracter en el indice Si al registro Cl
        Mov Usuario[Di], Cl ;Se mueve lo que se paso a Cl a InicialesNom
        Mov Contra[Di], Cl ;Se agrega al string de contrasena
        Inc Di ;Se aumenta el valor del registro Di
        Jmp BuscarEsp ;Se regresa al ciclo para buscar espacio
        
        
    ApPat: ;Ciclo para el apellido paterno
        Inc NumNom
        Mov Si, NumNom ;Movemos el valor de NumNom al registro Si
        Cmp Cadena[Si], "/" ;Buscamos un separador
        Je ApMat ;Se mueve a la etiqueta que resetea guarda el Apellido paterno y sus primeras 2 letras
        Cmp Cadena[Si], "$" ;Buscamos un terminador
        Je ApMat ;Se mueve a la etiqueta que resetea guarda el Apellido paterno y sus primeras 2 letras
        Cmp Cadena[Si], " " ;Buscamos un espacio, para imprimir el sig caracter
        Je ApPat ;Regresamos a buscar otro caracter
        
        Jmp ImpApPat ;En caso de que no sea ningun caracter terminal se va a imprimir 
        
    ImpApPat: ;Ciclo que guarda en Usuario y contra lo correspondiente
        Mov Si, NumNom
        Inc IndiceArr1 ;Se incrementa el valor de IndiceArr
        Mov Di, IndiceArr1 ;Se mueve al registro Di el valor de IndiceArr
        
        Mov Cl, Cadena[Si] ;Se mueve el caracter en el indice Si al registro Cl
        Mov Usuario[Di], Cl ;Se mueve lo que se paso a Cl a InicialesNom
        
        
        Mov Di, ContApPat ;Se mueve a Di el valor de ContApPat
        Cmp Di, 2 ;Este comparador es para saber cuantas letras se han guardado en la cont
        Je ApPat ;Si llega a 2 ya no se incrementa el numero y se omite la parte para guardarlo en la contrasena
        Inc IndiceArr2 ;Se incrementa la variable del arreglo 2 para cont
        Mov Di, IndiceArr2 ;Se mueve al registro Di el valor de IndiceArr
        Mov Contra[Di], Cl ;Se agrega al string de contrasena
        Inc ContApPat ;Se incrementa el valor para contar nada mas 2
        Jmp ApPat ;Si es menor a 2 se salta con esta linea a buscar mas caracteres
        
    ApMat:
        Inc NumNom
        Mov Si, NumNom ;Movemos el valor de NumNom al registro Si
        Cmp Cadena[Si], "/" ;Buscamos un separador
        Je CodPost ;Se mueve a la etiqueta que busca el Codigo Postal
        Cmp Cadena[Si], "$" ;Buscamos un terminador
        Je CodPost ;Se mueve a la etiqueta que resetea guarda el Apellido paterno y sus primeras 2 letras
        Cmp Cadena[Si], " " ;Buscamos un espacio, para imprimir el sig caracter
        Je ApMat ;Regresamos a buscar otro caracter
        
        Jmp ImpApMat ;En caso de que no sea ningun caracter terminal se va a imprimir 
        
    ImpApMat:
        Mov Di, ContApMat ;Se mueve a Di el valor de ContApPat
        Cmp Di, 2 ;Este comparador es para saber cuantas letras se han guardado en la cont
        Je ApMat ;Si llega a 2 ya no se incrementa el numero y se omite la parte para guardarlo en la contrasena
        
        Mov Si, NumNom ;Se guarda en el registro Si el valor de NumNom para guardar el caracter en contra
        Mov Cl, Cadena[Si] ;Se mueve el caracter en el indice Si al registro Cl
        Inc IndiceArr2 ;Se incrementa la variable del arreglo 2 para cont
        Mov Di, IndiceArr2 ;Se mueve al registro Di el valor de IndiceArr
        Mov Contra[Di], Cl ;Se agrega al string de contrasena
        Inc ContApMat ;Se incrementa el valor para contar nada mas 2
        Jmp ApMat ;Si es menor a 2 se salta con esta linea a buscar mas caracteres
        
    CodPost:
        Inc NumNom
        Mov Si, NumNom ;Movemos el valor de NumNom al registro Si
        Cmp Cadena[Si], "/" ;Buscamos un separador
        Je Direccion ;Se mueve a la etiqueta que busca el Codigo Postal
        Cmp Cadena[Si], "$" ;Buscamos un terminador
        Je Direccion ;Se mueve a la etiqueta que resetea guarda el Apellido paterno y sus primeras 2 letras
        Cmp Cadena[Si], " " ;Buscamos un espacio, para imprimir el sig caracter
        Je CodPost ;Regresamos a buscar otro caracter
        
        Jmp ImpCodPost ;En caso de que no sea ningun caracter terminal se va a imprimir 
        
    ImpCodPost: ;En este ciclo checa si es mayor que 3 el numero, si lo es pone en la Contra los 2 ultimos valores
        Inc NumCP ;Se aumenta el valor de la variable NumCP porque este es un numero valido (en teoria)
        Mov Di, NumCP ;Se mueve al registro Di el valor de NumCP para verificar si es menor que 3
        Cmp Di, 4 ;Se compara con el tres
        Jb CodPost ;si es menor que 3 se regresa a la etiqueta CodPost para seguir buscando
        ;Si es igual o mayor a 3 se guarda en contra
        Inc IndiceArr2 ;Se incrementa el indice del arreglo de la contra para meter un caracter
        Mov Di, IndiceArr2 ;Se mueve al registro Di para usarse
        Mov Cl, Cadena[Si] ;Se mueve al registro Cl lo que esta en la cadena en el indice Di para usarse
        Mov Contra[Di], Cl ;Se agrega al string de contrasena
        Jmp CodPost ;Se sigue buscando cosas en el codigo postal
        
    Direccion:
        Inc NumNom
        Mov Si, NumNom ;Movemos el valor de NumNom al registro Si
        Cmp Cadena[Si], "/" ;Buscamos un separador
        Je PreCarrera ;Se mueve a la etiqueta que busca el Codigo Postal
        Cmp Cadena[Si], "$" ;Buscamos un terminador
        Je Salir ;Se mueve a la etiqueta que resetea guarda el Apellido paterno y sus primeras 2 letras
        Cmp Cadena[Si], " " ;Buscamos un espacio, para imprimir el sig caracter
        Je Direccion ;Regresamos a buscar otro caracter
        
        Jmp ImpDireccion ;En caso de que no sea ningun caracter terminal se va a imprimir 
        
    ImpDireccion:
        Mov Di, NumDir 
        Cmp Di, 1
        Je Direccion
        Inc IndiceArr2 ;Se incrementa el valor de el indice para la contra para meter un caracter ahi
        Mov Di, IndiceArr2 ;Se mueve al registro Di el valor del indice de la contrasena
        Mov Cl, Cadena[Si] ;Se mueve a Cl el valor de la posicion en el arreglo Cadena (el caracter)
        Mov Contra[Di], Cl ;Se mete en la contra el caracter guardado en Cl
        Inc NumDir
        
    PreCarrera:
        Inc NumNom
        Mov Si, NumNom ;Movemos el valor de NumNom al registro Si
        Cmp Cadena[Si], "/" ;Buscamos un separador
        Je Carrera ;Se mueve a la etiqueta que busca el Codigo Postal
        Cmp Cadena[Si], "$" ;Buscamos un terminador
        Je Salir ;Se mueve a la etiqueta que resetea guarda el Apellido paterno y sus primeras 2 letras
        Cmp Cadena[Si], " " ;Buscamos un espacio, para imprimir el sig caracter
        Je PreCarrera ;Regresamos a buscar otro caracter
        
        Jmp PreCarrera
     
    Carrera:
        Inc NumNom
        Mov Si, NumNom ;Movemos el valor de NumNom al registro Si
        Cmp Cadena[Si], "/" ;Buscamos un separador
        Je Salir ;Se mueve a la salida
        Cmp Cadena[Si], "$" ;Buscamos un terminador
        Je Salir ;Se mueve a la salida
        Cmp Cadena[Si], " " ;Buscamos un espacio, para imprimir el sig caracter
        Je Carrera ;Regresamos a buscar otro caracter
        
        Jmp ImpCarrera ;En caso de que no sea ningun caracter terminal se va a imprimir 
        
    ImpCarrera:
        Inc IndiceArr1 ;Se incrementa el valor del indice para el arreglo del usuario
        Mov Di, IndiceArr1 ;Se mueve a Di el valor para el indice del usuario
        Mov Cl, Cadena[Si] ;Se mueve al registo Cl el valor del caracter en la posicion NumNom (guardado en Si)
        Mov Usuario[Di], Cl; Se mueve al arreglo Usuario lo que tengo en el registro CL
        Jmp Carrera ;Se regresa a buscara caracteres validos
        
    
    Salir:
    
        Inc IndiceArr1
        Inc IndiceArr2
        
        Mov Di, IndiceArr1
        Mov Cl, "$"
        Mov Usuario[Di], Cl
        
        Mov Di, IndiceArr2
        Mov Cl, "$"
        Mov Contra[Di], Cl
    
        ;Imprime la cadena "Usuario: "
        Mov Ah, 09h
        Mov Dx, offset usr;
        Int 21h
    
        ;Imprime lo que lleva Usuario
        Mov Ah, 09h
        Mov Dx, offset Usuario
        Int 21h
        
        ;Imprime un Salto de Linea
        Mov Ah, 09h
        Mov Dx, offset SL
        Int 21h
        
        ;Imprime la cadena "Contrasena :"
        Mov Ah, 09h
        Mov Dx, offset ctr
        Int 21h
        
        ;Se imprime la contrasena
        Mov Ah, 09h
        Mov Dx, offset Contra
        Int 21h
        
        ;Sale del programa
        .Exit
        Main endp
        end Main