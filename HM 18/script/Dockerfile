FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl
CMD ["echo", "Hello from my ECR image!"]
#0. Отримаємо YOUR_ACCOUNT_ID ECR репозиторію
# aws sts get-caller-identity --query "Account" --output text
#1. Потрібно отримати тимчасовий токен Від ECR для Докера
# aws ecr get-login-password --region us-east-1 \
# | docker login --username AWS --password-stdin \
# <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
#2. Можна тегнути збілджений імейдж
# docker tag my-custom-app:latest \
# <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/my-custom-app:latest
#3. Пушнемо імейдж в ECR 
# docker push
# <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/my-custom-app:latest