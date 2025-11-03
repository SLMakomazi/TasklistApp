# TasklistApp - Frontend

This is the frontend application for TasklistApp, built with React and designed to work with the Spring Boot backend. It provides a responsive user interface for managing tasks.

## 🚀 Features

- **Modern UI** - Built with React and Material-UI
- **Responsive Design** - Works on desktop and mobile devices
- **Real-time Updates** - Automatic refresh of task lists
- **Form Validation** - Client-side validation for better UX
- **Environment Configuration** - Easy configuration for different environments

## 🛠️ Prerequisites

- Node.js 16+ and npm 8+
- TasklistApp Backend running (default: http://localhost:8080)
- Git

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/TasklistApp.git
cd TasklistApp/frontend
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Configure Environment
Create a `.env` file in the frontend directory:
```env
REACT_APP_API_URL=http://localhost:8080/api
PORT=3000
```

### 4. Start Development Server
```bash
npm start
```
Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

## 🏗️ Project Structure

```
frontend/
├── public/               # Static files
├── src/
│   ├── components/      # Reusable UI components
│   ├── pages/           # Page components
│   ├── services/        # API service layer
│   ├── styles/          # Global styles
│   ├── utils/           # Utility functions
│   ├── App.js           # Main App component
│   └── index.js         # Application entry point
├── .env                 # Environment variables
├── package.json         # Dependencies and scripts
└── README.md            # This file
```

## 📦 Available Scripts

- `npm start` - Start development server
- `npm test` - Run tests
- `npm run build` - Build for production
- `npm run lint` - Run ESLint
- `npm run format` - Format code with Prettier

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `REACT_APP_API_URL` | Backend API URL | `http://localhost:8080/api` |
| `PORT` | Development server port | `3000` |

## 🧪 Testing

Run the test suite:
```bash
npm test
```

Run tests in watch mode:
```bash
npm test -- --watch
```

## 🚀 Deployment

### Production Build
```bash
npm run build
```
This creates an optimized production build in the `build` folder.

### Docker Build
```bash
docker build -t tasklistapp-frontend .
docker run -p 3000:80 tasklistapp-frontend
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Analyzing the Bundle Size

This section has moved here: [https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size](https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size)

### Making a Progressive Web App

This section has moved here: [https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app](https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app)

### Advanced Configuration

This section has moved here: [https://facebook.github.io/create-react-app/docs/advanced-configuration](https://facebook.github.io/create-react-app/docs/advanced-configuration)

### Deployment

This section has moved here: [https://facebook.github.io/create-react-app/docs/deployment](https://facebook.github.io/create-react-app/docs/deployment)

### `npm run build` fails to minify

This section has moved here: [https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify](https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify)
