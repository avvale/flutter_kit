# Backlog

- AuthProvider refactor:
  - Quitar función para cambiar authMode
    - Esto debería hacerse según el authMode que se pase al login()
      - Ver si entonces tiene sentido pasarlo a fkRunApp
  - Guardar el authMode en la sesión almacenada
- Los providers pueden recibir parámetros en el build, refactorizar para dejar de usar initializers
- Mejorar abstracción y funcionamiento providers, son poco flexibles en la integración general
- Abstracción para imágenes que admita distintas fuentes (local, red) y formatos (svg, png, bmp)
- IconBtn puede recibir 3 tipos de imagen, pudiendo usar solo una de ellas
  - Crear param único con clase abstracta y subclases que abarquen todas las posibilidades y su configuración necesaria
