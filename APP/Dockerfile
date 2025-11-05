# Imagem base oficial e leve
FROM python:3.11-slim

# Define o diretório da aplicação
WORKDIR /app

# Copia os arquivos necessários
COPY requirements.txt .
COPY templates/ ./templates/

# Instala dependências sem cache
RUN pip install --no-cache-dir -r requirements.txt

# Copia o código da aplicação
COPY app.py .

# Define variáveis de ambiente padrão
ENV FLASK_ENV=production
ENV PORT=5000

# Expõe a porta 5000
EXPOSE 5000

# Comando de inicialização
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
