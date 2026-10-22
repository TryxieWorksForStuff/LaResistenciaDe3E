# La Resistencia del 3.ºE
Sitio estático (HTML + JS, sin build). Funciona en GitHub Pages y se instala como PWA.

## Puesta en marcha
1. **Supabase**: crea un proyecto → SQL Editor → pega y ejecuta `supabase/schema.sql`.
2. Authentication → Providers → Email: **desactiva "Confirm email"**. (Los alumnos entran con usuario + contraseña; la app crea un correo interno `usuario@r3e.school`, así no se piden correos reales.)
3. En `index.html`, rellena `CFG.url` y `CFG.key` con la URL y la clave **anon/public** (Settings → API). Nunca uses la `service_role`.
4. Sube esta carpeta a un repositorio → Settings → Pages → rama `main`, carpeta raíz.
5. Regístrate en la app y vuelve al SQL Editor para ejecutar la última línea comentada del esquema (te vuelve admin).

Sin configurar `CFG` la app corre en **modo local**: todo se guarda en el navegador, no hay ranking ni sincronización.

## Contenido
Admin → editar el JSON del curso (materia → unidades → lecciones → preguntas). Tipos: `mc`, `tf`, `fill`, `order`, `match`. El curso de electrónica es **contenido de demostración**.

## Límites conocidos
- XP y rachas se calculan en el servidor, pero las respuestas se corrigen en el navegador (un alumno técnico podría falsear su puntaje; con el XP limitado a la primera vez por lección).
- Sin conexión: se abre la app y el último contenido; los resultados quedan en cola y se sincronizan al volver. Iniciar sesión por primera vez requiere internet.
- El icono es SVG; para instalación óptima en iPhone conviene añadir un PNG de 180 px.
- No incluido aún: tipo de pregunta con diagramas SVG, retos semanales, vista de progreso del grupo para el admin.
