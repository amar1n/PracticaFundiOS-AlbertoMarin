# PracticaFundiOS-AlbertoMarin

#### 1) Alternativas a 'isKindOfClass:'
Se puede utilizar **is** ya que este funciona con cualquier clase de Swift mientras que **isKindOfClass:** solo trabaja con subclases de NSObject o aquellas que implementen **NSObjectProtocol**

#### 2) Dónde guardar las imágenes de portada y los pdfs de los libro?
Estos datos los almaceno en el folder temporal de la Sandbox, para que se puedan liberar fácilmente en caso de un **Memory Warning**

#### 3) Cómo se ha diseñado la gestión de favoritos? Alternativas?
Almaceno los favoritos en las preferencias del usuario en la Sandbox como un diccionario cuyas claves son un identificador del libro, su **hashValue**, y el valor es un booleano que identifica que es favorito.

Una alternativa clara sería almacenar los favoritos en el servidor para aquellos usuarios VIP, es decir, que paguen!!!

#### 4) Cómo se entera la capa controller de un cambio en el modelo? Alternativas?
Los diferentes cambios en el modelo que tengo son los siguientes...

* El PDF del libro está disponible para que la *capa controller* la presente al usuario
* El modelo de la librería está disponible para ser que la *capa controller* la presente al usuario
* La imagen de la portada del libro está disponible para que la *capa controller* la presente al usuario
* Un libro ha cambiado su estatus de favorito, por lo que la *capa controller* debe actualizar la información mostrada al usuario

La *capa controller* se entera de todos estos cambios del modelo haciendo uso de **notificaciones**. Así que el modelo envía las notificaciones avisando a todo aquel que esté escuchando notificaciones.
En mi caso el modelo se compone de las clases...

* Library
* Book
* AsyncImage

Y la *capa controller* se compone de las clases...

* LibraryViewController
* BookViewController
* PDFViewController

Como mecanismos alternativos a las notificaciones podemos utilizar...

* Delegados. En mi caso lo he utilizado para establecer un mecanismo de interpretación a un evento dado entre los controladores de la librería y del libro. El controlador del libro debe saber interpretar el evento de seleccionar un libro en la tabla del controlador de la librería
* KVO, que desconozco su utilización

#### 5) El uso de reloadData es una aberración desde el punto de vista de rendimiento? Alternativas? Cuándo usarlas?
Según la documentación de Apple, el uso de reloadData SI afecta el rendimiento de la App y se desaconseja su uso en aquellos escenarios en los que se debe de actualizar el contenido de la tabla usando animaciones.
Sin embargo, comentan que para mejorar este aspecto de rendimiento, la tabla sólo repintará aquellos elementos que son visibles.

Una alternativa es utilizar el mecanismo de beginUpdates/endUpdates pero esta requiere que el programador realice las tareas de inserción, actualización y eliminación de elementos sobre la tabla.

Yo me decanté por el reloadData porque no requiro actualizar la tabla al modificar los favoritos utilizando una animación gráfica, además de lo sencillo de su utilización.

#### 6) Cómo actualizar el controlador que muestra un PDF al seleccionar otro libro en la tabla?
En este caso me decanté por el uso de notificaciones, es decir, el controlador de la librería envía una notificación cuando se selecciona un libro en su tabla. Así cualquier objeto que espere dicha notificación, podrá actuar en consecuencia.

# Extras

#### 1) Qué funcionalidades le añadirías antes de subirla a la App Store?
* Una barra de búsqueda
* Una zona para proponer la incorporación de libros al catálogo
* Una zona para añadir comentarios y que estos se visualicen en el detalle del libro
* Poder hacer zoom en el PDF para poder leer correctamente el libro
* Modificar la interfaz de usuario para que sea atractiva y no un mero ejercicio docente

#### 2) Subirla a la App Store
No lo he intentado

#### 3) Algo que se pueda monetizar?
Se puede ofrecer una librería que no contenga todos los PDFs disponibles y que para visualizarlos se requiera un pago.