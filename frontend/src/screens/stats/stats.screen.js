import React, { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import "./stats.style.scss";

function NotLanding() {
  const navigate = useNavigate();

  useEffect(() => {
    console.log("Rendered Stats screen.");
  }, []);

  const goBackClicked = () => {
    navigate("/");
  };

  return (
    <section id="entry-page">
      <form>
        <h2>Go Back!</h2>
        <button type="button" onClick={goBackClicked}>
          Go Back now
        </button>
      </form>
    </section>
  );
}

export default NotLanding;
