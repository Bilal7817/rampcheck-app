import sqlite3
import hashlib

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

def init_database():
    conn = sqlite3.connect('aircraft_maintenance.db')
    cursor = conn.cursor()
    
    with open('schema.sql', 'r') as f:
        schema = f.read()
        cursor.executescript(schema)
    
    demo_users = [
        ('admin', 'admin123', 'admin'),
        ('john_doe', 'tech123', 'technician'),
        ('jane_smith', 'tech123', 'technician'),
    ]
    
    for username, password, role in demo_users:
        cursor.execute('''
            INSERT OR IGNORE INTO users (username, password_hash, role)
            VALUES (?, ?, ?)
        ''', (username, hash_password(password), role))
    
    cursor.execute('''
        INSERT INTO jobs (title, description, aircraft_registration, status, priority, created_by)
        VALUES 
        ('Pre-flight Inspection', 'Standard pre-flight checklist', 'G-ABCD', 'open', 'high', 1),
        ('Engine Oil Check', 'Check and top up engine oil', 'G-EFGH', 'in_progress', 'medium', 1),
        ('Landing Gear Inspection', 'Visual inspection of landing gear', 'G-IJKL', 'completed', 'medium', 1)
    ''')
    
    cursor.execute('''
        INSERT INTO inspection_items (job_id, title, description, is_completed)
        VALUES 
        (1, 'Check fuel levels', 'Verify fuel tanks are adequately filled', 0),
        (1, 'Inspect tires', 'Check tire pressure and condition', 0),
        (1, 'Test lights', 'Verify all navigation and landing lights work', 0),
        (1, 'Check control surfaces', 'Ensure flaps, ailerons, rudder move freely', 0)
    ''')
    
    conn.commit()
    conn.close()
    
    print('Initialized database at aircraft_maintenance.db')
    print('Created demo users and jobs')

if __name__ == '__main__':
    init_database()