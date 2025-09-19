# ICC Claro App - Gestión de Coberturas

**Claro Puerto Rico - Aplicación Móvil de Gestión de Coberturas**

Una aplicación móvil desarrollada en Flutter para la gestión integral de coberturas, puntos de venta y monitoreo de competencia para Claro Puerto Rico.

## 📱 Descripción General

Esta aplicación es una herramienta especializada para Claro Puerto Rico que permite:

- **Gestión de Coberturas**: Visualización y administración de áreas de cobertura en un mapa interactivo de Puerto Rico
- **Puntos de Ventas (POS)**: Activación, visualización y desactivación de puntos de venta distribuidos por toda la isla
- **Monitoreo de Competencia**: Seguimiento de compañías competidoras que ofrecen servicios similares
- **Mapa Interactivo**: Visualización geográfica de todas las ubicaciones y coberturas

## 🚀 Características Principales

### 🗺️ Sistema de Mapas y Coberturas
- **Mapa interactivo** de Puerto Rico con Google Maps
- **Visualización de polígonos** de cobertura por tipo
- **Marcadores de antenas** y puntos de venta
- **Filtros dinámicos** por tipo de cobertura y antenas
- **Zoom y navegación** optimizada para la isla
- **Caché inteligente** para mejorar rendimiento

### 🏪 Gestión de Puntos de Ventas (POS)
- **Formularios de creación** de nuevos puntos de venta
- **Validación de coordenadas** dentro del perímetro de Puerto Rico
- **Gestión de contactos** y archivos por ubicación
- **Filtrado y búsqueda** avanzada de puntos de venta
- **Estados de activación/desactivación**
- **Información demográfica** y market share por municipio

### 🛣️ Sistema de Rutas ICC
- **Gestión de recorridos** con diferentes tipos de rutas
- **Estados de aprobación** por roles (Usuario, Asistente, Administrador)
- **Carga de documentos** y comentarios por ruta
- **Historial de cambios** y seguimiento de estados
- **Procesamiento por lotes** de rutas

### 🔐 Autenticación y Seguridad
- **Sistema de login** con JWT tokens
- **Gestión de roles** y permisos por usuario
- **Logout automático** por inactividad
- **Almacenamiento seguro** de credenciales
- **Notificaciones push** para eventos importantes

## 🏗️ Arquitectura Técnica

### 📁 Estructura del Proyecto
```
lib/
├── core/                    # Funcionalidades centrales
│   ├── config/             # Configuraciones (API, mapas, memoria)
│   ├── services/           # Servicios HTTP y autenticación
│   ├── utils/              # Utilidades, helpers y widgets
│   └── widgets/            # Widgets reutilizables
├── features/               # Módulos de funcionalidades
│   ├── authentication/     # Sistema de autenticación
│   ├── home/              # Pantalla principal
│   ├── features/map/      # Sistema de mapas y coberturas
│   └── routesicc/         # Gestión de rutas ICC
├── data/                  # Modelos de datos y repositorios
└── domain/                # Entidades y casos de uso
```

### 🔧 Tecnologías Utilizadas
- **Flutter**: Framework principal de desarrollo
- **Google Maps**: Visualización de mapas interactivos
- **Firebase**: Autenticación, notificaciones y almacenamiento
- **Provider**: Gestión de estado
- **Hive**: Base de datos local para caché
- **HTTP**: Comunicación con APIs REST
- **JWT**: Autenticación con tokens

### 🌐 APIs y Servicios

#### Configuración de Entornos
- **Desarrollo Local**: `http://192.168.1.5:7001/icc/api`
- **Servidor de Pruebas**: `https://webtest.prt.local/icc/api`
- **Producción**: Configuración específica del entorno de producción

#### Endpoints Principales
- **Autenticación**: (`/login-ws`, `/logout-ws`, `/getUserAuthorities`)
- **Coberturas**: (`/getPolygonTypes`, `/getBaseCoords`)
- **Puntos de venta**: (`/getPosLocationsInfo`, `/uploadPosLocationToDb`)
- **Rutas ICC**: (`/user-routes`, `/insertPosRoute`, `/finishRouteBatch`)
- **Municipios y datos geográficos**: (`/getMunicipalities`, `/getTowns`)
- **Recursos externos**: (`https://webtest.prt.local/geojson/municipalities.geojson`)

## 📋 Funcionalidades por Módulo

### 🗺️ Módulo de Mapas (`features/map`)
- **CoverageMap**: Widget principal del mapa de coberturas
- **MapCoverageScreen**: Pantalla de visualización de coberturas
- **CoverageProvider**: Gestión de estado de mapas y polígonos
- **MapServices**: Servicios de datos geográficos
- **DatabaseService**: Caché local de datos de mapas

### 🏪 Módulo de Puntos de Ventas
- **FormStateHandler**: Gestión de formularios de POS
- **PointOfSaleProvider**: Estado de puntos de venta
- **PosLocation**: Modelo de datos de ubicaciones
- **Validación geográfica**: Verificación de coordenadas en Puerto Rico

### 🛣️ Módulo de Rutas ICC (`routesicc`)
- **RouteService**: Servicios de gestión de rutas
- **RouteModel**: Modelo de datos de rutas
- **RouteScreen**: Pantalla de listado de rutas
- **DocumentsScreen**: Gestión de documentos por ruta

### 🔐 Módulo de Autenticación
- **LoginPage**: Pantalla de inicio de sesión
- **UserProvider**: Gestión de estado del usuario
- **LoginService**: Servicios de autenticación
- **JWT Token Management**: Manejo de tokens de acceso

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.5.4 o superior
- Dart SDK
- SVN Client (para clonar el repositorio)
- Android Studio / Xcode (para desarrollo móvil)
- Cuenta de Google Maps (para API key)

### Pasos de Instalación

#### 1. **Clonar el repositorio desde SVN**
   ```bash
   svn checkout http://10.0.113.12/svn/sirrepos/devel/ICC-mobile/
   cd ICC-mobile
   ```

#### 2. **Configurar entorno de desarrollo**
   ```bash
   # Limpiar proyecto
   flutter clean
   
   # Instalar dependencias
   flutter pub get
   ```

#### 3. **Configurar Firebase**
   - Agregar `google-services.json` en `android/app/` (Android)
   - Configurar `GoogleService-Info.plist` en `ios/Runner/` (iOS)

#### 4. **Configurar Google Maps**
   - Obtener API key de Google Maps
   - Configurar en `android/app/src/main/AndroidManifest.xml`
   - Configurar en `ios/Runner/AppDelegate.swift`

#### 5. **Configurar API endpoints**
   - Editar `lib/core/config/api_endpoints.dart`
   - Cambiar `baseUrl` según el entorno:
     ```dart
     // Para desarrollo local
     static const String baseUrl = 'http://192.168.1.5:7001/icc/api';
     
     // Para servidor de pruebas
     static const String baseUrl = 'https://webtest.prt.local/icc/api';
     ```

### 🚀 Proceso de Despliegue y Pruebas

#### **Para Desarrollo Local**
```bash
# Limpiar y reconstruir
flutter clean
flutter pub get

# Ejecutar en emulador/dispositivo
flutter run

# O ejecutar en emulador específico
flutter run -d <device-id>
```

#### **Para Generar APK de Pruebas**
```bash
# Limpiar proyecto
flutter clean

# Instalar dependencias
flutter pub get

# Generar APK de debug
flutter build apk --debug

# Generar APK de release (para pruebas)
flutter build apk --release

# APK se genera en: build/app/outputs/flutter-apk/
```

#### **Para Ejecutar en Emulador**
```bash
# Listar dispositivos disponibles
flutter devices

# Iniciar emulador Android
flutter emulators --launch <emulator-name>

# Ejecutar en emulador específico
flutter run -d android
```

#### **Para Pruebas en Dispositivo Físico**
```bash
# Conectar dispositivo Android via USB
# Habilitar depuración USB en el dispositivo

# Verificar dispositivo conectado
flutter devices

# Ejecutar en dispositivo
flutter run -d <device-id>
```

## 📱 Plataformas Soportadas

- ✅ **Android** (API 21+)

## 🔧 Configuración de Desarrollo

### 🌍 Gestión de Entornos

#### **Cambio de Entorno de API**
Para cambiar entre entornos de desarrollo y pruebas:

1. **Editar** `lib/core/config/api_endpoints.dart`
2. **Modificar** la variable `baseUrl`:
   ```dart
   class ApiEndpoints {
     // DESARROLLO LOCAL
     static const String baseUrl = 'http://192.168.1.5:7001/icc/api';
     
     // SERVIDOR DE PRUEBAS
     // static const String baseUrl = 'https://webtest.prt.local/icc/api';
     
     // PRODUCCIÓN
     // static const String baseUrl = 'https://api.claro.com/icc/api';
   }
   ```

3. **Limpiar y reconstruir** el proyecto:
   ```bash
   flutter clean
   flutter pub get
   ```

### 📋 Variables de Configuración
- **API Base URL**: Configurada en `lib/core/config/api_endpoints.dart`
- **Firebase**: Configurado en `firebase_options.dart`
- **Google Maps**: API key requerida en archivos de plataforma
- **Caché**: Configurado en `lib/core/config/memory_config.dart`

### 🔐 Permisos Requeridos
- **Ubicación**: Para funcionalidades de mapas y geolocalización
- **Cámara**: Para captura de fotos en rutas y documentos
- **Almacenamiento**: Para descarga y gestión de documentos
- **Notificaciones**: Para alertas del sistema y eventos importantes
- **Internet**: Para comunicación con APIs y servicios externos

### 🛠️ Comandos Útiles de Desarrollo

#### **Limpieza y Reconstrucción**
```bash
# Limpieza completa del proyecto
flutter clean

# Limpiar caché de Flutter
flutter pub cache clean

# Reinstalar dependencias
flutter pub get

# Verificar configuración
flutter doctor
```

#### **Debugging y Testing**
```bash
# Ejecutar con logs detallados
flutter run --verbose

# Ejecutar en modo debug
flutter run --debug

# Ejecutar tests
flutter test

# Analizar código
flutter analyze
```

#### **Generación de Builds**
```bash
# Build de debug (rápido, con debugging)
flutter build apk --debug

# Build de release (optimizado)
flutter build apk --release

# Build para diferentes arquitecturas
flutter build apk --split-per-abi
```

#### **Comandos SVN Útiles**
```bash
# Actualizar código desde el repositorio
svn update

# Ver estado de archivos modificados
svn status

# Agregar archivos nuevos
svn add <archivo>

# Commit de cambios
svn commit -m "Descripción del cambio"

# Ver historial de cambios
svn log

# Revertir cambios locales
svn revert <archivo>

# Ver diferencias
svn diff
```

## 📊 Versión Actual

**Versión**: 0.0.3  
**Última actualización**: 2024  
**Contacto**: soporte@claropr.com

## 🤝 Contribución

Esta aplicación está desarrollada específicamente para Claro Puerto Rico. Para contribuciones o reportes de bugs, contactar al equipo de desarrollo interno.

## 📄 Licencia

Aplicación propietaria de Claro Puerto Rico. Todos los derechos reservados.

---

**Desarrollado con ❤️ para Claro Puerto Rico**
