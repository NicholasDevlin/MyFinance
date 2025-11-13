import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS for Flutter app
  app.enableCors({
    origin: ['http://localhost:8080', 'http://127.0.0.1:8080', '*'], // Allow Flutter web
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    credentials: true,
  });

  // Enable validation pipe for DTOs
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    transform: true,
  }));

  // Setup Swagger Documentation
  const config = new DocumentBuilder()
    .setTitle('MyFinance API')
    .setDescription('Personal Finance Management System API')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT token',
        in: 'header',
      },
      'JWT-auth',
    )
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  // Enhanced console logging
  console.log('\n🚀 ================================');
  console.log('🎯 MyFinance Backend Started!');
  console.log('🌐 Server URL: http://localhost:' + port);
  console.log('📚 Swagger API Docs: http://localhost:' + port + '/api');
  console.log('🔧 Environment: ' + (process.env.NODE_ENV || 'development'));
  console.log('🗄️  Database: Connected to MySQL');
  console.log('================================ 🚀\n');
}
bootstrap();