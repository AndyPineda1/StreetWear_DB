DROP DATABASE IF EXISTS streetweardrop_db;
CREATE DATABASE streetweardrop_db;
USE streetweardrop_db;

CREATE TABLE Genero (
    id_Genero INT PRIMARY KEY,
    nombre_genero VARCHAR(20)
);

INSERT INTO Genero (id_Genero, nombre_genero) VALUES
(1, 'Masculino'),
(2, 'Femenino'),
(3, 'Otro');

CREATE TABLE Clientes (
    id_Cliente INT PRIMARY KEY,
    nombre_cliente VARCHAR(30),
    apellido_cliente VARCHAR(50),
    numero_cliente VARCHAR(20),
    correo_cliente VARCHAR(100),
    direccion_cliente VARCHAR(200),
    id_Genero INT,
    FOREIGN KEY (id_Genero) REFERENCES Genero(id_Genero)
);

INSERT INTO Clientes (id_Cliente, nombre_cliente, apellido_cliente, numero_cliente, correo_cliente, direccion_cliente, id_Genero) VALUES
(1, 'John', 'Doe', '1234567890', 'john@example.com', '123 Street, City, Country', 1),
(2, 'Jane', 'Doe', '0987654321', 'jane@example.com', '456 Street, City, Country', 2);

CREATE TABLE Distribuidores (
    id_Distribuidor INT PRIMARY KEY,
    nombre_Distribuidor VARCHAR(50),
    telefono_Distribuidor VARCHAR(20)
);

INSERT INTO Distribuidores (id_Distribuidor, nombre_Distribuidor, telefono_Distribuidor) VALUES
(1, 'Distribuidor A', '123456789'),
(2, 'Distribuidor B', '987654321');

CREATE TABLE Pedidos (
    id_Pedido INT PRIMARY KEY,
    estado_Pedido VARCHAR(50),
    fecha_Registro DATE,
    id_Cliente INT,
    direccion_Pedido VARCHAR(200),
    FOREIGN KEY (id_Cliente) REFERENCES Clientes(id_Cliente)
);

INSERT INTO Pedidos (id_Pedido, estado_Pedido, fecha_Registro, id_Cliente, direccion_Pedido) VALUES
(1, 'En proceso', '2024-03-17', 1, '123 Street, City, Country'),
(2, 'Entregado', '2024-03-16', 2, '456 Street, City, Country');

CREATE TABLE Categorias (
    id_Categoria INT PRIMARY KEY,
    nombre_Categoria VARCHAR(30)
);

INSERT INTO Categorias (id_Categoria, nombre_Categoria) VALUES
(1, 'Ropa'),
(2, 'Calzado');

CREATE TABLE TipoProducto (
    id_TipoProducto INT PRIMARY KEY,
    nombre_TipoProducto VARCHAR(30)
);

INSERT INTO TipoProducto (id_TipoProducto, nombre_TipoProducto) VALUES
(1, 'Camiseta'),
(2, 'Zapatos');

CREATE TABLE Productos (
    id_Producto INT PRIMARY KEY,
    nombre_Producto VARCHAR(50),
    cantidad_Producto INT,
    id_Categoria INT,
    id_TipoProducto INT,
    id_Distribuidor INT,
    FOREIGN KEY (id_Categoria) REFERENCES Categorias(id_Categoria),
    FOREIGN KEY (id_TipoProducto) REFERENCES TipoProducto(id_TipoProducto),
    FOREIGN KEY (id_Distribuidor) REFERENCES Distribuidores(id_Distribuidor)
);

INSERT INTO Productos (id_Producto, nombre_Producto, cantidad_Producto, id_Categoria, id_TipoProducto, id_Distribuidor) VALUES
(1, 'Camiseta Negra', 50, 1, 1, 1),
(2, 'Zapatos Deportivos', 30, 2, 2, 2);

CREATE TABLE DetallePedido (
    id_Pedido INT,
    id_Producto INT,
    FOREIGN KEY (id_Pedido) REFERENCES Pedidos(id_Pedido),
    FOREIGN KEY (id_Producto) REFERENCES Productos(id_Producto)
);

CREATE TABLE Comentarios (
    id_Comentario INT PRIMARY KEY,
    contenido VARCHAR(200),
    id_Pedido INT,
    FOREIGN KEY (id_Pedido) REFERENCES Pedidos(id_Pedido)
);

CREATE TABLE Direcciones (
    id_Direccion INT PRIMARY KEY,
    direccion VARCHAR(200),
    id_Cliente INT,
    FOREIGN KEY (id_Cliente) REFERENCES Clientes(id_Cliente)
);

CREATE TABLE TipoUsuario (
    id_TipoUsuario INT PRIMARY KEY,
    nombre_TipoUsuario VARCHAR(100)
);

INSERT INTO TipoUsuario (id_TipoUsuario, nombre_TipoUsuario) VALUES
(1, 'Administrador'),
(2, 'Usuario regular');

CREATE TABLE Usuario (
    id_Usuario INT PRIMARY KEY,
    username VARCHAR(30),
    nombre_Usuario VARCHAR(60),
    correo_Usuario VARCHAR(40),
    clave_Usuario VARCHAR(20),
    numero_Usuario VARCHAR(20),
    direccion_Usuario VARCHAR(200),
    id_TipoUsuario INT,
    FOREIGN KEY (id_TipoUsuario) REFERENCES TipoUsuario(id_TipoUsuario)
);

ALTER TABLE Clientes
ADD CONSTRAINT fk_Clientes_Genero FOREIGN KEY (id_Genero) REFERENCES Genero(id_Genero);

ALTER TABLE Direcciones
ADD CONSTRAINT fk_Direcciones_Clientes FOREIGN KEY (id_Cliente) REFERENCES Clientes(id_Cliente);

ALTER TABLE DetallePedido
ADD CONSTRAINT fk_DetallePedido_Pedidos FOREIGN KEY (id_Pedido) REFERENCES Pedidos(id_Pedido),
ADD CONSTRAINT fk_DetallePedido_Productos FOREIGN KEY (id_Producto) REFERENCES Productos(id_Producto);

ALTER TABLE Comentarios
ADD CONSTRAINT fk_Comentarios_Pedidos FOREIGN KEY (id_Pedido) REFERENCES Pedidos(id_Pedido);

ALTER TABLE Usuario
ADD CONSTRAINT fk_Usuario_TipoUsuario FOREIGN KEY (id_TipoUsuario) REFERENCES TipoUsuario(id_TipoUsuario);

DELIMITER //
CREATE TRIGGER actualizar_stock_producto
AFTER INSERT ON DetallePedido
FOR EACH ROW
BEGIN
    UPDATE Productos
    SET cantidad_Producto = cantidad_Producto - 1
    WHERE id_Producto = NEW.id_Producto;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_actualizar_cantidad_producto
AFTER INSERT ON DetallePedido
FOR EACH ROW
BEGIN
    UPDATE Productos 
    SET cantidad_Producto = cantidad_Producto - 1 
    WHERE id_Producto = NEW.id_Producto;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER revisar_cliente_insert
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Comentarios (contenido, id_Pedido) VALUES ('Nuevo cliente registrado', NULL);
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER revisar_pedido_update
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    INSERT INTO Comentarios (contenido, id_Pedido) VALUES ('El estado del pedido ha sido actualizado', NEW.id_Pedido);
END;
//
DELIMITER ;
