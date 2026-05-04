-- ============================================
-- CURSO BÍBLICO "LA FE DE JESÚS"
-- Script de creación de tablas - Supabase
-- ============================================

-- 1. Tabla de DISTRITOS
CREATE TABLE distritos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Tabla de IGLESIAS
CREATE TABLE iglesias (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  distrito_id UUID REFERENCES distritos(id) ON DELETE CASCADE,
  codigo TEXT UNIQUE NOT NULL, -- código único para que estudiantes se registren
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Tabla de PASTORES (usuarios admin)
CREATE TABLE pastores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  distrito_id UUID REFERENCES distritos(id) ON DELETE SET NULL,
  rol TEXT DEFAULT 'pastor' CHECK (rol IN ('superadmin', 'pastor')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Tabla de ESTUDIANTES
CREATE TABLE estudiantes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  telefono TEXT,
  iglesia_id UUID REFERENCES iglesias(id) ON DELETE SET NULL,
  instructor_nombre TEXT,
  instructor_rol TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Tabla de PROGRESO (una fila por lección completada)
CREATE TABLE progreso (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  estudiante_id UUID REFERENCES estudiantes(id) ON DELETE CASCADE,
  leccion_id INTEGER NOT NULL CHECK (leccion_id BETWEEN 1 AND 20),
  correctas INTEGER DEFAULT 0,
  total_preguntas INTEGER DEFAULT 3,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(estudiante_id, leccion_id)
);

-- ============================================
-- ÍNDICES para rendimiento con 10,000+ usuarios
-- ============================================
CREATE INDEX idx_estudiantes_iglesia ON estudiantes(iglesia_id);
CREATE INDEX idx_progreso_estudiante ON progreso(estudiante_id);
CREATE INDEX idx_iglesias_distrito ON iglesias(distrito_id);
CREATE INDEX idx_pastores_distrito ON pastores(distrito_id);

-- ============================================
-- PERMISOS (Row Level Security)
-- ============================================
ALTER TABLE distritos ENABLE ROW LEVEL SECURITY;
ALTER TABLE iglesias ENABLE ROW LEVEL SECURITY;
ALTER TABLE pastores ENABLE ROW LEVEL SECURITY;
ALTER TABLE estudiantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE progreso ENABLE ROW LEVEL SECURITY;

-- Políticas: permitir lectura y escritura pública por ahora
-- (después las ajustamos para seguridad)
CREATE POLICY "Permitir todo en distritos" ON distritos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en iglesias" ON iglesias FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en pastores" ON pastores FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en estudiantes" ON estudiantes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permitir todo en progreso" ON progreso FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- DATOS INICIALES: Tu usuario Super Admin
-- ============================================
-- Primero creamos un distrito de ejemplo
INSERT INTO distritos (nombre) VALUES ('Distrito Cartagena Norte');
INSERT INTO distritos (nombre) VALUES ('Distrito Cartagena Sur');

-- Iglesias de ejemplo (cambiar por las reales)
INSERT INTO iglesias (nombre, distrito_id, codigo)
SELECT 'Iglesia Renacer', id, 'RENACER-2026' FROM distritos WHERE nombre = 'Distrito Cartagena Norte';

INSERT INTO iglesias (nombre, distrito_id, codigo)
SELECT 'Iglesia Bethel', id, 'BETHEL-2026' FROM distritos WHERE nombre = 'Distrito Cartagena Norte';

INSERT INTO iglesias (nombre, distrito_id, codigo)
SELECT 'Iglesia Emaús', id, 'EMAUS-2026' FROM distritos WHERE nombre = 'Distrito Cartagena Sur';

-- Tu cuenta de Super Admin
INSERT INTO pastores (nombre, email, password_hash, rol)
VALUES ('Administrador Principal', 'cursofedejesus@gmail.com', 'admin2026', 'superadmin');
