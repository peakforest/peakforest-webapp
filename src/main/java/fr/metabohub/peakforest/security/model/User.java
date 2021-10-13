package fr.metabohub.peakforest.security.model;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Version;

import org.codehaus.jackson.annotate.JsonIgnore;
import org.codehaus.jackson.annotate.JsonProperty;

/**
 * @author Nils Paulhe
 * 
 */
@Entity
@Table(name = "users")
public class User implements Serializable {

	/**
	 * Serializable => default ID
	 */
	private static final long serialVersionUID = 1L;

	public static final int NORMAL = 0;
	public static final int CURATOR = 1;
	public static final int ADMIN = 2;

	public static final int SEARCH_ALL = 0;
	public static final int SEARCH_NOT_ACTIVATED = 1;
	public static final int SEARCH_ONLY_ACTIVATED = 2;

	public static final char PREF_LCMS = 'l';
	public static final char PREF_GCMS = 'g';
	public static final char PREF_LCMSMS = 'm';
	public static final char PREF_NMR = 'n';
	public static final char PREF_NMR2D = '2';

	@Id
	@GeneratedValue
	private long id;

	@Version
	private Long version;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created")
	// , nullable = false
	private Date created;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "updated")
	// , nullable = false
	private Date updated;

	@Column(nullable = false, unique = true)
	private String login;

	@Column(nullable = false, unique = true)
	private String email;

	@Column(nullable = false)
	private String password;

	@Column(nullable = false)
	private boolean admin = false;

	@Column(nullable = false)
	private boolean confirmed = false;

	@Column(nullable = false)
	private boolean curator = false;

	@Column(name = "main_technology", columnDefinition = " char(1) default '" + PREF_LCMS + "'") //
	private char mainTechnology = PREF_LCMS;

	@Column(nullable = true, unique = true)
	private String token = null;

	/**
	 * @return the id
	 */
	@JsonProperty("id")
	public long getId() {
		return id;
	}

	/**
	 * @param id
	 *            the id to set
	 */
	public void setId(long id) {
		this.id = id;
	}

	/**
	 * @return the version
	 */
	@JsonProperty("version")
	public Long getVersion() {
		return version;
	}

	/**
	 * @param version
	 *            the version to set
	 */
	public void setVersion(Long version) {
		this.version = version;
	}

	/**
	 * @return the login
	 */
	@JsonProperty("login")
	public String getLogin() {
		return login;
	}

	/**
	 * @param login
	 *            the login to set
	 */
	public void setLogin(String login) {
		this.login = login;
	}

	/**
	 * @return the email
	 */
	@JsonProperty("email")
	public String getEmail() {
		return email;
	}

	/**
	 * @param email
	 *            the email to set
	 */
	public void setEmail(String email) {
		this.email = email;
	}

	/**
	 * @return the password
	 */
	@JsonProperty("password")
	public String getPassword() {
		return password;
	}

	/**
	 * @param password
	 *            the password to set
	 */
	public void setPassword(String password) {
		this.password = password;
	}

	/**
	 * @return the admin
	 */
	@JsonProperty("isAdmin")
	public boolean isAdmin() {
		return admin;
	}

	/**
	 * @param admin
	 *            the admin to set
	 */
	public void setAdmin(boolean admin) {
		this.admin = admin;
	}

	// other methods
	/**
	 * Prune user (for easy retrun in json)
	 * 
	 * @return
	 */
	public User prune() {
		User u = new User();
		u.setLogin(this.login);
		u.setEmail(this.email);
		u.setAdmin(false);
		u.setPassword(null);
		u.setToken(null);
		return u;
	}

	/**
	 * @return
	 */
	@JsonProperty("isConfirmed")
	public boolean isConfirmed() {
		return confirmed;
	}

	/**
	 * @param confirmed
	 *            the confirmed to set
	 */
	public void setConfirmed(boolean confirmed) {
		this.confirmed = confirmed;
	}

	// /**
	// *
	// */
	// @PrePersist
	// protected void onCreate() {
	// created = new Date();
	// }
	//
	// /**
	// *
	// */
	// @PreUpdate
	// protected void onUpdate() {
	// updated = new Date();
	// }

	/**
	 * @return the created
	 */
	@JsonProperty("created")
	public Date getCreated() {
		return created;
	}

	/**
	 * @param created
	 *            the created to set
	 */
	public void setCreated(Date created) {
		this.created = created;
	}

	/**
	 * @return the updated
	 */
	@JsonProperty("updated")
	public Date getUpdated() {
		return updated;
	}

	/**
	 * @param updated
	 *            the updated to set
	 */
	public void setUpdated(Date updated) {
		this.updated = updated;
	}

	/**
	 * @return the curator
	 */
	@JsonProperty("isCurator")
	public boolean isCurator() {
		return curator;
	}

	/**
	 * @param curator
	 *            the curator to set
	 */
	public void setCurator(boolean curator) {
		this.curator = curator;
	}

	/**
	 * @return
	 */
	public char getMainTechnology() {
		return mainTechnology;
	}

	/**
	 * @param mainTechnology
	 */
	public void setMainTechnology(char mainTechnology) {
		this.mainTechnology = mainTechnology;
	}

	/**
	 * @return the token
	 */
	@JsonIgnore
	public String getToken() {
		return token;
	}

	/**
	 * @param token
	 *            the token to set
	 */
	public void setToken(String token) {
		this.token = token;
	}

}
