import React, { useState, useEffect } from "react";

import { useNavigate } from "react-router-dom";
import "./Landing.style.scss";

function Landing() {
  const navigate = useNavigate();
  const [count, setCount] = useState(0);

  useEffect(() => {
    console.log("Rendered Landing screen.");
  }, []);

  const navigateClicked = () => {
    navigate("/notlanding");
  };

  const stopPressed = () => {
    const requestOptions = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
    };
    fetch("http://localhost:3000/crawler/stop", requestOptions)
      .then((response) => response.json())
      .then((data) => {
        console.log(JSON.stringify(data));
      });
  };

  return (
    <section id="entry-page">
      <form>
        <h2>Welcome Back!</h2>
        <button type="button" onClick={navigateClicked}>
          See some Stats
        </button>
        <button type="button" onClick={stopPressed}>
          Stop the Crawler
        </button>
      </form>
    </section>
  );
}

export default Landing;
