DROP DATABASE if EXISTS streetweardrop_db;
CREATE DATABASE streetweardrop_db;
USE streetweardrop_db;
CREATE TABLE Genero (
    id_Genero INT PRIMARY KEY,
    nombre_genero VARCHAR(20)
);
CREATE TABLE Departamento (
    id_Departamento INT PRIMARY KEY,
    nombre_Departamento VARCHAR(60)
);
CREATE TABLE Clientes (
    id_Cliente INT PRIMARY KEY,
    nombre_cliente VARCHAR(30),
    apellido_cliente VARCHAR(50),
    numero_cliente VARCHAR(20),
    correo_cliente VARCHAR(100),
    direccion_cliente VARCHAR(200),
    id_Genero INT,
    id_Departamento INT,
    FOREIGN KEY (id_Genero) REFERENCES Genero(id_Genero),
    FOREIGN KEY (id_Departamento) REFERENCES Departamento(id_Departamento)
);
CREATE TABLE Distribuidores (
    id_Distribuidor INT PRIMARY KEY,
    nombre_Distribuidor VARCHAR(50),
    telefeno_Distribuidor VARCHAR(20),
    id_Departamento INT,
    FOREIGN KEY (id_Departamento) REFERENCES Departamento(id_Departamento)
);
CREATE TABLE Pedidos (
    id_Pedido INT PRIMARY KEY,
    estado_Pedido VARCHAR(50),
    fecha_Registro DATE,
    id_Cliente INT,
    direccion_Pedido VARCHAR(200),
    FOREIGN KEY (id_Cliente) REFERENCES Clientes(id_Cliente)
);
CREATE TABLE Categorias (
    id_Categoria INT PRIMARY KEY,
    nombre_Categoria VARCHAR(30)
);
CREATE TABLE TipoProducto (
    id_TipoProducto INT PRIMARY KEY,
    nombre_TipoProducto VARCHAR(30)
);
CREATE TABLE Productos (
    id_Producto INT PRIMARY KEY,
    nombre_Producto VARCHAR(50),
    cantidad_Producto INT,
    id_Categoria INT,
    id_TipoProducto INT,
    FOREIGN KEY (id_Categoria) REFERENCES Categorias(id_Categoria),
    FOREIGN KEY (id_TipoProducto) REFERENCES TipoProducto(id_TipoProducto)
);

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
CREATE TABLE DetallePedido (
    id_Pedido INT,
    id_Producto INT,
    FOREIGN KEY (id_Pedido) REFERENCES Pedidos(id_Pedido),
    FOREIGN KEY (id_Producto) REFERENCES Productos(id_Producto)
);

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
CREATE TABLE Bitacora (
    id_Bitacora INT PRIMARY KEY,
    id_Cliente INT,
    id_Pedido INT,
    id_Producto INT,
    FOREIGN KEY (id_Cliente) REFERENCES Clientes(id_Cliente),
	 FOREIGN KEY (id_Pedido) REFERENCES Pedidos(id_Pedido), 
	 FOREIGN KEY (id_Producto) REFERENCES Productos(id_Producto)   
);

DELIMITER //
CREATE TRIGGER revisar_cliente_insert
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_Cliente) VALUES (NEW.id_Cliente);
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER revisar_pedido_update
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (id_Pedido) VALUES (NEW.id_Pedido);
END;
//
DELIMITER ;
CREATE TABLE TipoUsuario (
    id_TipoUsuario INT PRIMARY KEY,
    nombre_TipoUsuario VARCHAR(100)
);

DELIMITER //
CREATE TRIGGER evitar_eliminacion_tipo_usuario
BEFORE DELETE ON TipoUsuario
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar registros de la tabla TipoUsuario.';
END;
//
DELIMITER ;
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

ALTER TABLE Clientes
ADD CONSTRAINT fk_Clientes_Departamento FOREIGN KEY (id_Departamento) REFERENCES Departamento(id_Departamento);

ALTER TABLE Departamento
ADD CONSTRAINT uq_nombre_departamento UNIQUE (nombre_Departamento);

ALTER TABLE Clientes
ADD CONSTRAINT chk_numero_cliente_length CHECK (LENGTH(numero_cliente) <= 20);