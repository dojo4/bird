(function() {
    let email_input;
    let submit_button; 
    domready(function () {
        submit_button = document.getElementById('submit_button');
        email_input = document.getElementById('email_input');
        if (submit_button) {
            submit_button.onclick = validateForm;
        }
        if (document.getElementById('bgvid')) {
            document.getElementById('bgvid').playbackRate = 0.5;
        }
        // email_input.change = keypressHandler;
    });
    
    function validateForm(e) {
        const value = email_input.value;
        const error_display = document.getElementById('errors');

        if (emailIsValid(value)) {
            return true;
        }
        error_display.innerText = 'Email address is invalid.'
        return false;
    }

    function keypressHandler(e) {
        const value = this.value;
        const error_display = document.getElementById('errors');
        if (emailIsValid(value)) {
            submit_button.disabled = false;
            error_display.innerText = '';
        } else if (value.length < 6) {
            submit_button.disabled = true;
        } else {
            submit_button.disabled = true;
            error_display.innerText = 'Email address is invalid.'
        }
    }

    function emailIsValid (email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
    }

    
})()
