module RequestSpecHelper
  def json_response
    JSON.parse(response.body)
  end

  def auth_headers(user)
    post '/login', params: { user: { email: user.email, password: 'password123' } }
    { 'Authorization' => response.headers['Authorization'] }
  end
end
