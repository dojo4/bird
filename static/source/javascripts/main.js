(function() {
    let email_input;
    let submit_button; 
    domready(function () {
        submit_button = document.getElementById('submit_button');
        email_input = document.getElementById('email_input');
        email_input.onkeydown = keypressHandler;
        email_input.onclick = keypressHandler;
        // email_input.change = keypressHandler;
    });
    
    
    function keypressHandler(e) {
        console.log(this.value)
        const error_display = document.getElementById('errors');
        if (emailIsValid(this.value)) {
            submit_button.disabled = false;
            error_display.innerText = '';
        } else {
            error_display.innerText = 'Email address is invalid.'
            submit_button.disabled = true;
        }
    }
    function emailIsValid (email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
    }

    
})()
