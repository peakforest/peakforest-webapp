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

//import com.fasterxml.jackson.annotation.JsonIgnore;
//import com.fasterxml.jackson.annotation.JsonProperty;

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

	@JsonProperty("id")
	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	@JsonProperty("version")
	public Long getVersion() {
		return version;
	}

	public void setVersion(Long version) {
		this.version = version;
	}

	@JsonProperty("login")
	public String getLogin() {
		return login;
	}

	public void setLogin(String login) {
		this.login = login;
	}

	@JsonProperty("email")
	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@JsonProperty("password")
	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	@JsonProperty("isAdmin")
	public boolean isAdmin() {
		return admin;
	}

	public void setAdmin(boolean admin) {
		this.admin = admin;
	}

	// other methods

	public User prune() {
		User u = new User();
		u.setLogin(this.login);
		u.setEmail(this.email);
		u.setAdmin(false);
		u.setPassword(null);
		u.setToken(null);
		return u;
	}

	@JsonProperty("isConfirmed")
	public boolean isConfirmed() {
		return confirmed;
	}

	public void setConfirmed(boolean confirmed) {
		this.confirmed = confirmed;
	}

	@JsonProperty("created")
	public Date getCreated() {
		return created;
	}

	public void setCreated(Date created) {
		this.created = created;
	}

	@JsonProperty("updated")
	public Date getUpdated() {
		return updated;
	}

	public void setUpdated(Date updated) {
		this.updated = updated;
	}

	@JsonProperty("isCurator")
	public boolean isCurator() {
		return curator;
	}

	public void setCurator(boolean curator) {
		this.curator = curator;
	}

	public char getMainTechnology() {
		return mainTechnology;
	}

	public void setMainTechnology(char mainTechnology) {
		this.mainTechnology = mainTechnology;
	}

	@JsonIgnore
	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}

}
