# Ecommerce-DataWareHouse
Creación de una base de datos transaccional (OLTP) en combinación con un data warehouse con una dimensión lentamente cambiante de tipo 2,
  ## Pasos de proyecto:
- Creación de base de datos transaccional
  - Estructura de la base de datos:
    - **Tabla de Proveedores**: ProveedorID, NombreProveedor, NombreContacto, Direccion, Ciudad, CodigoPostal, Pais, Telefono, Clasificacion, EsProveedorCertificado, FechaInicio, FechaFin.
    - **Tabla de Productos**: ProductoID, NombreProducto, Categoria, Precio, Costo, ProveedorID.
    - **Tabla de Clientes**: ClienteID, Nombre, Apellido, CorreoElectronico, Telefono, Direccion, Ciudad, CodigoPostal, Pais.
    - **Tabla de Monedas**: MonedaID, Cotizacion, Moneda, Fecha.
    - **Tabla de Pedidos**: PedidoID, ClienteID, FechaPedido, FechaEnvio, CostoEnvio, MontoTotal.
    - **Tabla de DetallesPedidos**: DetallePedidoID, PedidoID, ProductoID, Cantidad, PrecioUnitario.
    - **Tabla de Envios**: EnvioID, PedidoID, FechaEntrega, Transportista, EstadoEnvio.
    - **Tabla de Devoluciones**: DevolucionID, PedidoID, ProductoID, FechaDevolucion, MotivoDevolucion, EstadoDevolucion.
    - **Tabla de Inventarios**: InventarioID, ProductoID, CantidadDisponible, FechaActualizacion.
~~~
Comentario: La estructuracion de las tablas para la tienda 
a enfoco mas en la parte de producto, ya que queria aplicar
 la demension lentamente cambiante (T2) al proveedor del 
 producto
~~~
~~~
Para la creacion del DW se uso una estructura de un esquema
estrella, que reprenta muy bien la solucion para la 
creacion de un DW, simple y especifico para el analisis
~~~
- Creacion de base de datos de negocios (Data warehouse)
  - Estructura del DW:
    - **Tabla DimTiempo**: TiempoID, Fecha, Anio, Mes, NombreMes, Trimestre, NombreTrimestre, DiaSemana, NombreDiaSemana, DiaDelAnio.
    - **Tabla DimProducto**: ProductoID, NombreProducto, Categoria, PrecioActual.
    - **Tabla DimCliente**: ClienteID, NombreCompleto, CorreoElectronico, Ciudad, Direccion, Pais.
    - **Tabla DimProveedor**: ProveedorID, ProveedorSK, NombreProveedor, Ciudad, Pais, Clasificacion, EsProveedorCertificado, FechaInicio, FechaFin, Activo.
    - **Tabla DimMoneda**: MonedaID, Cotizacion, Moneda, Fecha.
    - **Tabla FactVentas**: VentaID, TiempoID, ProductoID, ClienteID, ProveedorID, PedidoID, Cantidad, PrecioUnitario, MontoTotal, Ganancia, FechaPedido, FechaEnvio, CostoEnvio, EstadoEnvio.
- Script con py para creación de los datos para la transaccional
- Inserción de los datos a la DB transaccional
- Script de ETL para el proceso de populado
- Populado de los datos desde la transaccional a la data warehouse
