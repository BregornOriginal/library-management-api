require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

  describe 'POST /signup' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            name: 'John Doe',
            email: 'john@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            role: 'member'
          }
        }
      end

      it 'creates a new user' do
        expect {
          post '/signup', params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns status 200' do
        post '/signup', params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'returns JWT token in authorization header' do
        post '/signup', params: valid_params
        expect(response.headers['Authorization']).to be_present
      end

      it 'returns user data' do
        post '/signup', params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to include(
          'email' => 'john@example.com',
          'name' => 'John Doe',
          'role' => 'member'
        )
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          user: {
            name: 'John Doe',
            email: 'invalid_email',
            password: 'pass',
            password_confirmation: 'pass'
          }
        }
      end

      it 'does not create a new user' do
        expect {
          post '/signup', params: invalid_params
        }.not_to change(User, :count)
      end

      it 'returns unprocessable_entity status' do
        post '/signup', params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with missing name' do
      let(:params_without_name) do
        {
          user: {
            email: 'john@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'returns error message' do
        post '/signup', params: params_without_name
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to include("Name can't be blank")
      end
    end
  end

  describe 'POST /login' do
    context 'with valid credentials' do
      it 'returns status 200' do
        post '/login', params: { user: { email: user.email, password: 'password123' } }
        expect(response).to have_http_status(:ok)
      end

      it 'returns JWT token in authorization header' do
        post '/login', params: { user: { email: user.email, password: 'password123' } }
        expect(response.headers['Authorization']).to be_present
      end

      it 'returns user data' do
        post '/login', params: { user: { email: user.email, password: 'password123' } }
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to include(
          'email' => user.email,
          'name' => user.name,
          'role' => user.role
        )
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized status' do
        post '/login', params: { user: { email: user.email, password: 'wrong_password' } }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not return JWT token' do
        post '/login', params: { user: { email: user.email, password: 'wrong_password' } }
        expect(response.headers['Authorization']).to be_nil
      end
    end

    context 'with non-existent user' do
      it 'returns unauthorized status' do
        post '/login', params: { user: { email: 'nonexistent@example.com', password: 'password123' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /logout' do
    let(:auth_headers) do
      post '/login', params: { user: { email: user.email, password: 'password123' } }
      { 'Authorization' => response.headers['Authorization'] }
    end

    context 'with valid JWT token' do
      it 'returns status 200' do
        delete '/logout', headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it 'returns success message' do
        delete '/logout', headers: auth_headers
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Logged out successfully.')
      end
    end

    context 'without JWT token' do
      it 'returns success status (stateless tokens)' do
        delete '/logout'
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
