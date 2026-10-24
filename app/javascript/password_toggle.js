document.addEventListener("click", (event) => {
  const toggleButton = event.target.closest(".toggle-password");

  if (!toggleButton) return;

  // Find the password field associated with this button.
  const targetId = toggleButton.dataset.target;
  const passwordField = document.getElementById(targetId);

  if (!passwordField) return;

  const icon = toggleButton.querySelector("i");
  const isHidden = passwordField.type === "password";

  // Toggle password visibility.
  passwordField.type = isHidden ? "text" : "password";

  // Update the eye icon.
  if (icon) {
    icon.classList.toggle("fa-eye", !isHidden);
    icon.classList.toggle("fa-eye-slash", isHidden);
  }

  // Update accessibility attributes.
  toggleButton.setAttribute(
    "aria-label",
    isHidden ? "Hide password" : "Show password"
  );

  toggleButton.setAttribute("aria-pressed", String(isHidden));
});