class SessionController
  def create
    email = email[:email]
    password = password[:password]

    user = User.authenticate(email, password)

    if user
      redirect_to :home
    else
      redirect_to :login
    end
  end
end