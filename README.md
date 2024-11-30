# Ecommerce-DataWareHouse
Creación de una base de datos transaccional (OLTP) en combinación con un data warehouse con una dimensión lentamente cambiante de tipo 2,
  ## Pasos de proyecto:
- Creación de base de datos transaccional
  - Estructura de la base de datos:
    - Tabla de Proveedores
    - Tabla de Productos
    - Tabla de Clientes
    - Tabla de Monedas
    - Tabla de Pedidos
    - Tabla de DetallesPedidos
    - Tabla de Envios
    - Tabla de Devoluciones
    - Tabla de Inventarios 
### Comentario: Me enfoque mas en el producto para cuestion de armar bien la dimension lentamente cambiante
- Creacion de base de datos de negocios (Data warehouse)
  - Estructura de la base de datos:
    - Tabla DimTiempo
    - Tabla DimProducto
    - Tabla DimCliente
    - Tabla DimProveedor
    - Tabla DimMoneda
    - Tabla FactVentas
- Script con py para creación de los datos para la transaccional
- Inserción de los datos a la DB transaccional
- Script de ETL para el proceso de populado
- Populado de los datos desde la transaccional a la data warehouse
