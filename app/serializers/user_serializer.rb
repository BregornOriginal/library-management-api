class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :name, :role, :created_at
end
