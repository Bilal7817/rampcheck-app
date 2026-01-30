from flask import Flask, request, jsonify
import sqlite3
import hashlib
from datetime import datetime

app = Flask(__name__)

DATABASE = 'aircraft_maintenance.db'
API_KEY = 'api_warehouse_student_key_1234567890abcdef'

def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

def require_api_key(f):
    def decorated(*args, **kwargs):
        api_key = request.headers.get('X-API-Key') or request.headers.get('Authorization', '').replace('Bearer ', '')
        if api_key != API_KEY:
            return jsonify({'error': 'Invalid API key'}), 401
        return f(*args, **kwargs)
    decorated.__name__ = f.__name__
    return decorated

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

@app.route('/api/v1/users', methods=['GET'])
def get_users():
    conn = get_db()
    users = conn.execute('SELECT id, username, role, created_at, updated_at FROM users').fetchall()
    conn.close()
    return jsonify([dict(u) for u in users])

@app.route('/api/v1/users', methods=['POST'])
def create_user():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    role = data.get('role', 'technician')
    
    if not username or not password:
        return jsonify({'error': 'Username and password required'}), 400
    
    conn = get_db()
    try:
        cursor = conn.execute(
            'INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)',
            (username, hash_password(password), role)
        )
        conn.commit()
        user_id = cursor.lastrowid
        user = conn.execute('SELECT id, username, role, created_at, updated_at FROM users WHERE id = ?', (user_id,)).fetchone()
        conn.close()
        return jsonify(dict(user)), 201
    except sqlite3.IntegrityError:
        conn.close()
        return jsonify({'error': 'Username already exists'}), 409

@app.route('/api/v1/users/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    
    if not username or not password:
        return jsonify({'error': 'Username and password required'}), 400
    
    conn = get_db()
    user = conn.execute('SELECT * FROM users WHERE username = ?', (username,)).fetchone()
    conn.close()
    
    if user and user['password_hash'] == hash_password(password):
        return jsonify({
            'id': user['id'],
            'username': user['username'],
            'role': user['role'],
            'message': 'Login successful'
        })
    
    return jsonify({'error': 'Invalid credentials'}), 401

@app.route('/api/v1/jobs', methods=['GET'])
@require_api_key
def get_jobs():
    conn = get_db()
    jobs = conn.execute('SELECT * FROM jobs ORDER BY created_at DESC').fetchall()
    conn.close()
    return jsonify([dict(j) for j in jobs])

@app.route('/api/v1/jobs/<int:job_id>', methods=['GET'])
@require_api_key
def get_job(job_id):
    conn = get_db()
    job = conn.execute('SELECT * FROM jobs WHERE id = ?', (job_id,)).fetchone()
    if not job:
        conn.close()
        return jsonify({'error': 'Job not found'}), 404
    
    items = conn.execute('SELECT * FROM inspection_items WHERE job_id = ?', (job_id,)).fetchall()
    attachments = conn.execute('SELECT * FROM attachments WHERE job_id = ?', (job_id,)).fetchall()
    conn.close()
    
    return jsonify({
        'job': dict(job),
        'inspection_items': [dict(i) for i in items],
        'attachments': [dict(a) for a in attachments]
    })

@app.route('/api/v1/jobs', methods=['POST'])
@require_api_key
def create_job():
    data = request.json
    title = data.get('title')
    description = data.get('description')
    aircraft_registration = data.get('aircraft_registration')
    status = data.get('status', 'open')
    priority = data.get('priority', 'medium')
    created_by = data.get('created_by')
    
    if not title or not created_by:
        return jsonify({'error': 'Title and created_by required'}), 400
    
    conn = get_db()
    cursor = conn.execute(
        'INSERT INTO jobs (title, description, aircraft_registration, status, priority, created_by) VALUES (?, ?, ?, ?, ?, ?)',
        (title, description, aircraft_registration, status, priority, created_by)
    )
    conn.commit()
    job_id = cursor.lastrowid
    job = conn.execute('SELECT * FROM jobs WHERE id = ?', (job_id,)).fetchone()
    conn.close()
    
    return jsonify(dict(job)), 201

@app.route('/api/v1/jobs/<int:job_id>', methods=['PUT'])
@require_api_key
def update_job(job_id):
    data = request.json
    conn = get_db()
    
    job = conn.execute('SELECT * FROM jobs WHERE id = ?', (job_id,)).fetchone()
    if not job:
        conn.close()
        return jsonify({'error': 'Job not found'}), 404
    
    status = data.get('status', job['status'])
    priority = data.get('priority', job['priority'])
    completed_at = data.get('completed_at')
    
    conn.execute(
        'UPDATE jobs SET status = ?, priority = ?, completed_at = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        (status, priority, completed_at, job_id)
    )
    conn.commit()
    
    updated_job = conn.execute('SELECT * FROM jobs WHERE id = ?', (job_id,)).fetchone()
    conn.close()
    
    return jsonify(dict(updated_job))

@app.route('/api/v1/inspection_items', methods=['POST'])
@require_api_key
def create_inspection_item():
    data = request.json
    job_id = data.get('job_id')
    title = data.get('title')
    description = data.get('description')
    
    if not job_id or not title:
        return jsonify({'error': 'job_id and title required'}), 400
    
    conn = get_db()
    cursor = conn.execute(
        'INSERT INTO inspection_items (job_id, title, description) VALUES (?, ?, ?)',
        (job_id, title, description)
    )
    conn.commit()
    item_id = cursor.lastrowid
    item = conn.execute('SELECT * FROM inspection_items WHERE id = ?', (item_id,)).fetchone()
    conn.close()
    
    return jsonify(dict(item)), 201

@app.route('/api/v1/inspection_items/<int:item_id>', methods=['PUT'])
@require_api_key
def update_inspection_item(item_id):
    data = request.json
    conn = get_db()
    
    item = conn.execute('SELECT * FROM inspection_items WHERE id = ?', (item_id,)).fetchone()
    if not item:
        conn.close()
        return jsonify({'error': 'Inspection item not found'}), 404
    
    is_completed = data.get('is_completed', item['is_completed'])
    notes = data.get('notes', item['notes'])
    completed_at = datetime.now().isoformat() if is_completed else None
    
    conn.execute(
        'UPDATE inspection_items SET is_completed = ?, notes = ?, completed_at = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        (is_completed, notes, completed_at, item_id)
    )
    conn.commit()
    
    updated_item = conn.execute('SELECT * FROM inspection_items WHERE id = ?', (item_id,)).fetchone()
    conn.close()
    
    return jsonify(dict(updated_item))

@app.route('/api/v1/sync', methods=['POST'])
@require_api_key
def sync_data():
    data = request.json
    jobs_to_sync = data.get('jobs', [])
    items_to_sync = data.get('inspection_items', [])
    
    conn = get_db()
    synced_jobs = []
    synced_items = []
    
    for job_data in jobs_to_sync:
        if 'id' in job_data and job_data['id']:
            conn.execute(
                'UPDATE jobs SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
                (job_data.get('status'), job_data['id'])
            )
        else:
            cursor = conn.execute(
                'INSERT INTO jobs (title, description, aircraft_registration, status, priority, created_by) VALUES (?, ?, ?, ?, ?, ?)',
                (job_data.get('title'), job_data.get('description'), job_data.get('aircraft_registration'), 
                 job_data.get('status'), job_data.get('priority'), job_data.get('created_by'))
            )
            job_data['id'] = cursor.lastrowid
        synced_jobs.append(job_data)
    
    for item_data in items_to_sync:
        if 'id' in item_data and item_data['id']:
            conn.execute(
                'UPDATE inspection_items SET is_completed = ?, notes = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
                (item_data.get('is_completed'), item_data.get('notes'), item_data['id'])
            )
        else:
            cursor = conn.execute(
                'INSERT INTO inspection_items (job_id, title, description, is_completed, notes) VALUES (?, ?, ?, ?, ?)',
                (item_data.get('job_id'), item_data.get('title'), item_data.get('description'),
                 item_data.get('is_completed'), item_data.get('notes'))
            )
            item_data['id'] = cursor.lastrowid
        synced_items.append(item_data)
    
    conn.commit()
    conn.close()
    
    return jsonify({
        'message': 'Sync successful',
        'synced_jobs': synced_jobs,
        'synced_items': synced_items
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')