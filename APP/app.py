from flask import Flask, render_template, g
import pymysql
import os

app = Flask(__name__)

DB_HOST = '172.16.1.116'
DB_USER = os.getenv('DB_USER', 'app_user')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'SenhaForte123!')
DB_NAME = os.getenv('DB_NAME', 'nextgenz')

def get_db():
    """
    Cria e retorna uma conexão com o banco MariaDB.
    """
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor  # Retorna dicionários
        )
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/books')
def books():
    try:
        db = get_db()
        with db.cursor() as cursor:

            sql_query = """
                SELECT books.title, authors.name 
                FROM books 
                JOIN authors ON books.author_id = authors.id
            """
            cursor.execute(sql_query)
            
            books = cursor.fetchall()
        return render_template('books.html', books=books)
    except Exception as e:
        return f"Erro ao acessar banco: {e}"

@app.route('/authors')
def authors():
    try:
        db = get_db()
        with db.cursor() as cursor:
            cursor.execute("SELECT * FROM authors")
            authors = cursor.fetchall()
        return render_template('authors.html', authors=authors)
    except Exception as e:
        return f"Erro ao acessar banco: {e}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
