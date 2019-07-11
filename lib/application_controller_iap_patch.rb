module GoogleIAP
    module ApplicationIAPAuthPatch
  
        # Returns the current user or nil if no user is logged in
        # and starts a session if needed
        def find_current_user
            user = nil

            if (emailaddress = request.headers["X-Goog-Authenticated-User-Email"].to_s.presence)
                emailaddress.sub! 'accounts.google.com:', ''
                
                su = User.find_by_mail(emailaddress)
                if su && su.active?
                    logger.info("  IAP Login for : #{emailaddress} (id=#{su.id})") if logger
                    user = su
                else
                    logger.error("  Failed IAP Login for : #{emailaddress} (not found)") if logger
                    render_error :message => 'Automatic Login User Not Found', :status => 403
                end
            end

            # store current ip address in user object ephemerally
            user.remote_ip = request.remote_ip if user

            user
        end
  
    end
end