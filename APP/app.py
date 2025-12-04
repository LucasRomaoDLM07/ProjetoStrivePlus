from flask import Flask, render_template, g
import pymysql
import os

app = Flask(__name__)

# ----------- AUTORES (lista local para testes) -----------
authors = [
    {
        "id": 1,
        "name": "George Orwell",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/7/7e/George_Orwell_press_photo.jpg",
        "bio": "George Orwell foi um romancista britânico, autor de 1984 e A Revolução dos Bichos."
    },
    {
        "id": 2,
        "name": "J.K. Rowling",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/5/5d/J._K._Rowling_2010.jpg",
        "bio": "J.K. Rowling é a autora britânica famosa pela série Harry Potter."
    },
    {
        "id": 3,
        "name": "J.R.R. Tolkien",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/d/d4/J._R._R._Tolkien%2C_ca._1925.jpg",
        "bio": "Tolkien foi um escritor britânico, autor de O Senhor dos Anéis e O Hobbit."
    },
    {
        "id": 4,
        "name": "Agatha Christie",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/c/cf/Agatha_Christie.png",
        "bio": "A Dama do Crime, autora de mais de 80 romances policiais."
    },
    {
        "id": 5,
        "name": "Stephen King",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/e/e3/Stephen_King%2C_Comicon.jpg",
        "bio": "Stephen King é o maior autor de terror contemporâneo."
    },
    {
        "id": 6,
        "name": "Isaac Asimov",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/3/34/Isaac.Asimov01.jpg",
        "bio": "Asimov foi um escritor e bioquímico célebre por Fundação e Eu, Robô."
    },
    {
        "id": 7,
        "name": "Arthur Conan Doyle",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/6/68/Conan_Doyle_%28LOC%29.jpg",
        "bio": "Criador de Sherlock Holmes e um dos pilares do romance investigativo."
    },
    {
        "id": 8,
        "name": "Machado de Assis",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/5/5f/Brazilian_writer_Machado_de_Assis.png",
        "bio": "O maior escritor brasileiro, autor de Dom Casmurro e Memórias Póstumas."
    },
    {
        "id": 9,
        "name": "Clarice Lispector",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/7/7c/%281920-1977%29_Clarice_Lispector_6zxkp_please_credit%28palette.fm%29_%28cropped%29.png",
        "bio": "Clarice Lispector foi uma romancista brasileira ícone do modernismo."
    },
    {
        "id": 10,
        "name": "Franz Kafka",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/4/4c/Kafka1906_cropped.jpg",
        "bio": "Kafka foi um escritor tcheco, conhecido por A Metamorfose."
    },
    {
        "id": 11,
        "name": "Fyodor Dostoevsky",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/e/e0/Dostoevsky_1879.jpg",
        "bio": "Autor russo de Crime e Castigo e Os Irmãos Karamázov."
    },
    {
        "id": 12,
        "name": "Victor Hugo",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/e/e6/Victor_Hugo_by_%C3%89tienne_Carjat_1876_-_full.jpg",
        "bio": "Romancista francês autor de Os Miseráveis."
    },
    {
        "id": 13,
        "name": "Gabriel García Márquez",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/d/dc/Gabriel_Garc%C3%ADa_M%C3%A1rquez_02_%28cropped%29.jpg",
        "bio": "Escritor colombiano vencedor do Nobel."
    },
    {
        "id": 14,
        "name": "Neil Gaiman",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/b/bc/Kyle-cassidy-neil-gaiman-April-2013.jpg",
        "bio": "Escritor britânico autor de Sandman, Coraline e Deuses Americanos."
    },
    {
        "id": 15,
        "name": "H.P. Lovecraft",
        "photo_url": "https://upload.wikimedia.org/wikipedia/commons/d/d3/Howard_Phillips_Lovecraft_in_1915_%282%29.jpg",
        "bio": "Criador do horror cósmico."
    }
]


# ----------- CONFIG BANCO -----------
DB_HOST = '10.0.2.159'
DB_USER = os.getenv('DB_USER', 'app_user')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'SenhaForte123!')
DB_NAME = os.getenv('DB_NAME', 'nextgenz')


def get_db():
    if "_database" not in g:
        g._database = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
    return g._database


@app.teardown_appcontext
def close_connection(exception):
    db = g.pop("_database", None)
    if db is not None:
        db.close()


# ----------- ROTAS -----------

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/books')
def books_list():
    try:
        db = get_db()
        with db.cursor() as cursor:
            cursor.execute("SELECT id, title, cover_url FROM books ORDER BY id DESC")
            books = cursor.fetchall()

        return render_template("books.html", books=books)

    except Exception as e:
        return f"Erro ao acessar banco: {e}"


@app.route("/authors")
def author_list():
    return render_template("authors.html", authors=authors)


@app.route('/book/<int:book_id>')
def book_detail(book_id):
    try:
        db = get_db()
        with db.cursor() as cursor:
            cursor.execute("""
                SELECT
                    books.id,
                    books.title,
                    books.description,
                    books.published_year,
                    books.cover_url,
                    authors.name AS author_name,
                    authors.photo_url AS author_photo
                FROM books
                JOIN authors ON books.author_id = authors.id
                WHERE books.id = %s
            """, (book_id,))

            book = cursor.fetchone()

        if not book:
            return "Livro não encontrado", 404

        return render_template("book_detail.html", book=book)

    except Exception as e:
        return f"Erro ao acessar banco: {e}"

@app.route("/author/<int:author_id>")
def author_detail(author_id):
    author = next((a for a in authors if a["id"] == author_id), None)
    if not author:
        return "Autor não encontrado", 404
    return render_template("authors_detail.html", author=author)


# ----------- RUN APP -----------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
