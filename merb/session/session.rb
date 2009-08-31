module Merb
  module Session
    
    # The Merb::Session module gets mixed into Merb::SessionContainer to allow 
    # app-level functionality; it will be included and methods will be available 
    # through request.session as instance methods.
    
    def anon_user
      anon = User.first(:id => self[:anon_user_id])

      # build anonymous user if it doesnt already exist
      unless anon
        anon = User.create_anonymous!
        self[:anon_user_id] = anon.id
      end
      
      # convert to real account if possible
      self.user = anon if anon.active?

      return anon
    end
    
    # force a user
    def user!
      user || anon_user
    end
    alias :user_or_anon :user!
    
    def token_user(auth_token = nil)
      token_user = User.first(:id => self[:token_user_id])
      
      unless token_user
        token_user = User.first(:auth_token => auth_token) if auth_token
        self[:token_user_id] = token_user.id if token_user
      end
      
      return token_user
    end
    
  end
end