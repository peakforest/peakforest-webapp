package fr.metabohub.peakforest.security;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

import javax.naming.Context;
import javax.naming.NamingEnumeration;
import javax.naming.directory.Attributes;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;

import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.StandardPasswordEncoder;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.security.services.UserManagementService;
import fr.metabohub.peakforest.utils.Utils;

/**
 * @author Nils Paulhe
 * 
 */
public class SpectralDatabaseAuthenticationProvider implements AuthenticationProvider {

	/* (non-Javadoc)
	 * 
	 * @see
	 * org.springframework.security.authentication.AuthenticationProvider#authenticate(org.springframework
	 * .security.core.Authentication) */
	@Override
	public Authentication authenticate(Authentication authentication) throws AuthenticationException {

		// 0 - init
		UsernamePasswordAuthenticationToken auth = (UsernamePasswordAuthenticationToken) authentication;

		// 1. retrieve entered user credentials
		String submittedUserID = String.valueOf(auth.getPrincipal());

		// 2. login
		if (submittedUserID.contains("@")) {
			return authenticateByEmail(authentication);
		} else {
			return authenticateByLDAP(authentication);
		}

	}

	/**
	 * @param authentication
	 * @return
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	private Authentication authenticateByLDAP(Authentication authentication) {

		// 0 - init
		UsernamePasswordAuthenticationToken auth = (UsernamePasswordAuthenticationToken) authentication;

		// 1. retrieve entered user credentials
		String submittedUserLdapLogin = String.valueOf(auth.getPrincipal());
		String submittedPassword = String.valueOf(auth.getCredentials());

		// 2. retrieve matching user in meta DB
		User user = null;
		try {
			user = UserManagementService.readLogin(submittedUserLdapLogin);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// 3. check login / password
		boolean isLdapUser = false;
		String userLDAPmail = null;

		// 3.A - search ldap
		String userPrincipal = null;
		Hashtable envLogin = new Hashtable();
		envLogin.put(Context.INITIAL_CONTEXT_FACTORY,
				Utils.bundleConf.getString("ldap.initial_context_factory"));
		envLogin.put(Context.PROVIDER_URL, Utils.bundleConf.getString("ldap.provider_url"));
		envLogin.put(Context.SECURITY_AUTHENTICATION,
				Utils.bundleConf.getString("ldap.security_authentication"));
		DirContext ctxLogin = null;
		String searchFilter = Utils.bundleConf.getString("ldap.filter").replace("USERNAME",
				submittedUserLdapLogin);
		String searchBase = Utils.bundleConf.getString("ldap.searchbase");
		try {
			ctxLogin = new InitialDirContext(envLogin);
			SearchControls constraints = new SearchControls();
			constraints.setSearchScope(SearchControls.SUBTREE_SCOPE);
			NamingEnumeration answer = ctxLogin.search(searchBase, searchFilter, constraints);
			while (answer != null && answer.hasMore()) {
				SearchResult sr = (SearchResult) answer.next();
				userPrincipal = sr.getName() + "," + searchBase;
			}
		} catch (Throwable e) {
			// e.printStackTrace();
		} finally {
			if (ctxLogin != null) {
				try {
					ctxLogin.close();
				} catch (Exception e) {
				}
			}
		}

		// 3.B - login ldap
		Hashtable env = new Hashtable();
		env.put(Context.INITIAL_CONTEXT_FACTORY, Utils.bundleConf.getString("ldap.initial_context_factory"));
		env.put(Context.PROVIDER_URL, Utils.bundleConf.getString("ldap.provider_url"));
		env.put(Context.SECURITY_AUTHENTICATION, Utils.bundleConf.getString("ldap.security_authentication"));
		env.put(Context.SECURITY_PRINCIPAL, userPrincipal);
		env.put(Context.SECURITY_CREDENTIALS, submittedPassword);
		DirContext ctx = null;
		try {
			ctx = new InitialDirContext(env);
			Attributes attrs = ctx.getAttributes(userPrincipal);
			// debug 1.5: if no email in LDAP info, set it as LDAP login
			try {
				userLDAPmail = attrs.get("mail").get().toString().toLowerCase();
			} catch (NullPointerException npe) {
				userLDAPmail = submittedUserLdapLogin;
			}
			isLdapUser = true;
		} catch (Throwable e) {
			e.printStackTrace();
			isLdapUser = false;
		} finally {
			if (ctx != null) {
				try {
					ctx.close();
				} catch (Exception e) {
				}
			}
		}

		// fail authentication if user name does not exist in meta DB
		if (isLdapUser == false)
			throw new UsernameNotFoundException(submittedUserLdapLogin);

		// fail authentication if user name does not exist in meta DB
		if (user == null && userLDAPmail != null) {
			// user not in DB, add it!
			user = new User();
			user.setLogin(submittedUserLdapLogin);
			user.setEmail(userLDAPmail);
			// LDAP user:
			// user.setConfirmed(true);
			user.setPassword("ldap");
			try {
				UserManagementService.create(user);
			} catch (Exception e) {
				// e.printStackTrace();
				throw new UsernameNotFoundException(submittedUserLdapLogin);
			}
		}

		// 4. Grant access
		List<GrantedAuthority> grantedAuthorities = new ArrayList<GrantedAuthority>();
		grantedAuthorities.add(new SimpleGrantedAuthority("ROLE_USER"));
		if (user.isAdmin())
			grantedAuthorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
		if (user.isConfirmed())
			grantedAuthorities.add(new SimpleGrantedAuthority("ROLE_EDITOR"));
		if (user.isCurator())
			grantedAuthorities.add(new SimpleGrantedAuthority("ROLE_CURATOR"));

		// prune password & return auth. token
		user.setPassword(null);
		return new UsernamePasswordAuthenticationToken(user, null, grantedAuthorities);
	}

	/**
	 * @param authentication
	 * @return
	 */
	private Authentication authenticateByEmail(Authentication authentication) {
		// 0 - init
		UsernamePasswordAuthenticationToken auth = (UsernamePasswordAuthenticationToken) authentication;

		// 1. retrieve entered user credentials
		String submittedUserMail = String.valueOf(auth.getPrincipal());
		String submittedPassword = String.valueOf(auth.getCredentials());

		// 2. retrieve matching user in meta DB
		User user = null;
		try {
			user = UserManagementService.read(submittedUserMail);

		} catch (Exception e) {
			e.printStackTrace();
		}

		// fail authentication if user name doesnt exist in meta DB
		if (user == null)
			throw new UsernameNotFoundException(submittedUserMail);

		// 3. compare passwords
		StandardPasswordEncoder encoder = new StandardPasswordEncoder();
		if (!encoder.matches(submittedPassword, user.getPassword())) {
			throw new BadCredentialsException("Incorrect Password.");
		}

		// 4. Grant access
		List<GrantedAuthority> grantedAuthorities = new ArrayList<GrantedAuthority>();
		grantedAuthorities.add(new SimpleGrantedAuthority("ROLE_USER"));
		if (user.isAdmin())
			grantedAuthorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
		if (user.isConfirmed())
			grantedAuthorities.add(new SimpleGrantedAuthority("ROLE_EDITOR"));
		if (user.isCurator())
			grantedAuthorities.add(new SimpleGrantedAuthority("ROLE_CURATOR"));

		// prune password & return auth. token
		user.setPassword(null);
		return new UsernamePasswordAuthenticationToken(user, null, grantedAuthorities);
	}

	/* (non-Javadoc)
	 * 
	 * @see org.springframework.security.authentication.AuthenticationProvider#supports(java.lang.Class) */
	@Override
	public boolean supports(Class<?> authentication) {
		return (UsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication));
	}
}
