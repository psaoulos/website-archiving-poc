import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import {
  BrowserRouter,
  Routes,
  Route,
} from "react-router-dom";
import reportWebVitals from "./reportWebVitals";
import Stats from "./screens/stats/stats.screen";
import Landing from "./screens/landing/Landing.screen"

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <BrowserRouter>
    <Routes>
      <Route path="/" element={<Landing />} />
      <Route path="landing" element={<Landing />} />
      <Route path="stats" element={<Stats />} />
    </Routes>
  </BrowserRouter>,
);

reportWebVitals();
