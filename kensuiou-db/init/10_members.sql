INSERT INTO members (student_id, nickname) VALUES
('25622021', 'Gakkun'),
('25622038', 'Tomohiro'),
('25622041', 'Ryochinup'),
('25622047', 'Daichaaan'),
('25622014', 'Kotaro')
ON CONFLICT (id) DO NOTHING;
