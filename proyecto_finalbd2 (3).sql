-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 18-11-2023 a las 16:03:57
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `proyecto_finalbd2`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarStock` (IN `producto_id` INT, IN `cantidad_comprada` INT)   BEGIN
UPDATE Producto SET CantidadStock = CantidadStock - cantidad_comprada WHERE ID_Producto = producto_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CalcularTotalCompra` (IN `carrito_id` INT, OUT `total` DECIMAL(10,2))   BEGIN
SELECT SUM(Cantidad * PrecioUnitario) INTO total
FROM DetalleCarrito WHERE ID_Carrito = carrito_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarProductoCarrito` (IN `detalle_id` INT)   BEGIN
   DELETE FROM DetalleCarrito WHERE ID_Detalle = detalle_id;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CalcularPrecioTotal` (`Cantidad` INT, `PrecioUnitario` DECIMAL(10,2)) RETURNS DECIMAL(10,2)  BEGIN
    RETURN Cantidad * PrecioUnitario;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ContarProductosStockBajo` (`umbral_stock` INT) RETURNS INT(11)  BEGIN
    DECLARE cantidad_stock_bajo INT;

    SELECT COUNT(*)
    INTO cantidad_stock_bajo
    FROM Producto
    WHERE CantidadStock < umbral_stock;

    RETURN cantidad_stock_bajo;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `UsuarioExiste` (`ID_Usuario` INT) RETURNS TINYINT(1)  BEGIN
   RETURN EXISTS (SELECT 1 FROM usuario WHERE ID_Usuario = ID_Usuario);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrito`
--

CREATE TABLE `carrito` (
  `ID_Carrito` int(11) NOT NULL,
  `ID_Usuario` int(11) DEFAULT NULL,
  `FechaCreacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `carrito`
--

INSERT INTO `carrito` (`ID_Carrito`, `ID_Usuario`, `FechaCreacion`) VALUES
(1, 1, '2023-11-14 09:13:11'),
(2, 2, '2023-11-14 09:13:11'),
(4, 1, '2023-11-14 04:06:20');

--
-- Disparadores `carrito`
--
DELIMITER $$
CREATE TRIGGER `ActualizarFechaCreacionCarrito` BEFORE INSERT ON `carrito` FOR EACH ROW BEGIN
    SET NEW.FechaCreacion = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallecarrito`
--

CREATE TABLE `detallecarrito` (
  `ID_Detalle` int(11) NOT NULL,
  `ID_Carrito` int(11) DEFAULT NULL,
  `ID_Producto` int(11) DEFAULT NULL,
  `Cantidad` int(11) DEFAULT NULL,
  `PrecioUnitario` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detallecarrito`
--

INSERT INTO `detallecarrito` (`ID_Detalle`, `ID_Carrito`, `ID_Producto`, `Cantidad`, `PrecioUnitario`) VALUES
(1, 1, 1, 3, 1500000.00),
(2, 1, 3, 2, 35000.00),
(3, 2, 3, 2, 26500.00),
(4, 2, 4, 1, 120000.00);

--
-- Disparadores `detallecarrito`
--
DELIMITER $$
CREATE TRIGGER `ActualizarStockDespuesDeCompra` AFTER INSERT ON `detallecarrito` FOR EACH ROW BEGIN
   UPDATE Producto SET CantidadStock = CantidadStock - NEW.Cantidad WHERE ID_Producto = NEW.ID_Producto;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ValidarStockAntesDeCompra` BEFORE INSERT ON `detallecarrito` FOR EACH ROW BEGIN
    IF NEW.Cantidad > (SELECT CantidadStock FROM Producto WHERE ID_Producto = NEW.ID_Producto) THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficiente stock para este producto.';
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `informacionpersonal`
--

CREATE TABLE `informacionpersonal` (
  `ID_Usuario` int(11) NOT NULL,
  `Apellido` varchar(255) DEFAULT NULL,
  `CorreoElectronico` varchar(255) DEFAULT NULL,
  `Direccion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `informacionpersonal`
--

INSERT INTO `informacionpersonal` (`ID_Usuario`, `Apellido`, `CorreoElectronico`, `Direccion`) VALUES
(1, 'Perez', 'juan@example.com', 'Calle A, Ciudad'),
(2, 'Lopez', 'maria@example.com', 'Calle B, Ciudad');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `ID_Producto` int(11) NOT NULL,
  `Nombre` varchar(255) DEFAULT NULL,
  `Descripcion` text DEFAULT NULL,
  `Precio` decimal(10,2) DEFAULT NULL,
  `CantidadStock` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`ID_Producto`, `Nombre`, `Descripcion`, `Precio`, `CantidadStock`) VALUES
(1, 'Motocierra', 'stihl 381', 1500000.00, 5),
(2, 'Fertilizante', 'fertilizante para mais', 25000.00, 30),
(3, 'glifosato', 'matamalezas concentrado', 35000.00, 8),
(4, 'electro bomba', 'electrobomba de 110V', 120000.00, 15);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `ID_Usuario` int(11) NOT NULL,
  `Nombre` varchar(255) DEFAULT NULL,
  `Contraseña` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`ID_Usuario`, `Nombre`, `Contraseña`) VALUES
(1, 'Juan', 'contraseña1'),
(2, 'Maria', 'contraseña2');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `carrito`
--
ALTER TABLE `carrito`
  ADD PRIMARY KEY (`ID_Carrito`),
  ADD KEY `ID_Usuario` (`ID_Usuario`);

--
-- Indices de la tabla `detallecarrito`
--
ALTER TABLE `detallecarrito`
  ADD PRIMARY KEY (`ID_Detalle`),
  ADD UNIQUE KEY `UQ_CarritoProducto` (`ID_Carrito`,`ID_Producto`),
  ADD KEY `ID_Producto` (`ID_Producto`);

--
-- Indices de la tabla `informacionpersonal`
--
ALTER TABLE `informacionpersonal`
  ADD PRIMARY KEY (`ID_Usuario`),
  ADD UNIQUE KEY `CorreoElectronico` (`CorreoElectronico`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`ID_Producto`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`ID_Usuario`);

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `carrito`
--
ALTER TABLE `carrito`
  ADD CONSTRAINT `carrito_ibfk_1` FOREIGN KEY (`ID_Usuario`) REFERENCES `usuario` (`ID_Usuario`);

--
-- Filtros para la tabla `detallecarrito`
--
ALTER TABLE `detallecarrito`
  ADD CONSTRAINT `detallecarrito_ibfk_1` FOREIGN KEY (`ID_Carrito`) REFERENCES `carrito` (`ID_Carrito`),
  ADD CONSTRAINT `detallecarrito_ibfk_2` FOREIGN KEY (`ID_Producto`) REFERENCES `producto` (`ID_Producto`);

--
-- Filtros para la tabla `informacionpersonal`
--
ALTER TABLE `informacionpersonal`
  ADD CONSTRAINT `informacionpersonal_ibfk_1` FOREIGN KEY (`ID_Usuario`) REFERENCES `usuario` (`ID_Usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
