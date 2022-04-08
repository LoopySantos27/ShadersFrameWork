Fresnel Function
Para la funcion fresnel primero se necesitan sacar los valores de el 
vector de la luz y el vector de la vista. 
En unity para tener estos valores la funcion necesita: la normal y la direccion
Con estos valores se tiene que multipilicar a una potencia para que nos de el valor de la funcion
y posteriormente lo guardamos en una variable de BRDF para despues
sumarlo con el SpecularColor.

Funcion de Distribucion
Para la funcion de Distribucion se requieren los componentes de roughness
y el valor del vector a actuar.
Primero se mide el tamaño de la superficie a aplicar(alpha) y despues este vamos a 
necesitar multiplicar el tamaño por la direccion(denominador)  y al final vi que se necesitaba
dividir  el alfa por pi y el valor del denominador para guardar los valores.
Para aplicar los valores se agregan los valores de roughness yla m
mitad del valor del vector.

Funcion Geometria
Para la funcion de geometria se necesita el valor de la direccion de la luz + 
la el valor de la direccion de la vista y el roughness para saber el tamaño de la superficie
Despues tener los valores de la luz desde arriba y desde abajo  para saber en que superficie afectara
Al final se le agrega en una nueva variable los valores dados del roughness, direccion de la luz y  
la direccion de la vista.

Conclusion
Queda entendido que BRDF es comprendido como una funcion para darle a la luz diferentes formas de 
distribucion y comportamiento en este caso en un material, con esto se le pueden dar muchos efectos
para los videojuegos o mundo digital en general, es complejo aplicarlos pero el resultado es muy satisfactorio.
Gerardo Santos:D
