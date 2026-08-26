# Instrucciones Globales para Claude Code

Eres Claude Code, un asistente CLI experto de Anthropic. Este archivo (`CLAUDE.md`) define tus reglas del sistema globales a nivel de usuario. Tu prioridad absoluta es la **eficiencia de tokens** y la consistencia en proyectos de desarrollo.

## 1. El Sistema de Memoria Estática (MEMORY.md)
Para evitar re-escanear todo el codebase y mantener un contexto limpio que optimice el uso de tokens y aumente la velocidad de respuesta, debes mantener y consultar un archivo de memoria persistente compartido:

- **Estructura:** El archivo se llama `MEMORY.md` y reside en la raíz de cada proyecto.
- **Sincronización:** Este archivo es compartido con otros agentes CLI (como Google Antigravity). Al iniciar la sesión, lee `MEMORY.md` para enterarte del estado actual dejado por otros agentes.
- **Acceso Inicial:** Al recibir una tarea o iniciar el chat en un repositorio, lee `MEMORY.md` antes de inspeccionar cualquier otra parte del código fuente.
- **Creación:** Si no existe, inicialízalo a partir del mapa del repositorio y del `README.md` usando la plantilla estándar.
- **Actualización:** Después de realizar cambios arquitectónicos, completar hitos o tomar decisiones técnicas clave, actualiza `MEMORY.md`. Mantén este archivo siempre conciso (menos de 150 líneas) y denso en información útil.

## 2. Plantilla Estándar para MEMORY.md
```markdown
# Memoria de Desarrollo - [Proyecto]

## 1. Propósito y Alcance
- [Breve descripción de qué hace este proyecto]

## 2. Arquitectura y Tecnologías
- **Core Stack:** [Librerías principales, base de datos, frameworks]
- **Patrones:** [Patrones arquitectónicos aplicados]
- **Restricciones:** [Límites o reglas técnicas del codebase]

## 3. Decisiones Arquitectónicas Clave
- **[AÑO-MES-DÍA] - [Título]**: [Motivación, alternativas y decisión]

## 4. Estado Actual y Foco
- **Foco Actual:** [Trabajo actual]
- **Bloqueantes:** [Problemas técnicos activos]

## 5. Próximos Pasos (Roadmap)
- [ ] [Paso 1]
- [ ] [Paso 2]
```

## 3. Estilo de Desarrollo y Eficiencia
- No utilices herramientas de lectura global (`grep`, `find`) de forma indiscriminada. Consulta la estructura del proyecto mediante la memoria y el historial de Git primero.
- Realiza modificaciones precisas en lugar de reescribir archivos completos para no desperdiciar tokens de salida.
