/**
 * 
 */
package fr.metabohub.peakforest.model.maps;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.MappedSuperclass;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Version;

import org.codehaus.jackson.annotate.JsonIgnore;

//import com.fasterxml.jackson.annotation.JsonIgnore;

/**
 * This class defines the inherited id attribute for all model's objects in
 * classes
 * 
 * @author Nils Paulhe
 * 
 */
@MappedSuperclass
public abstract class AbstractMapObject {

	@Id
	@GeneratedValue
	private long id;

	@Version
	private Long version;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "created")
	private Date created = new Date();

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "updated")
	private Date updated;

	/**
	 * @return the id
	 */
	public long getId() {
		return id;
	}

	/**
	 * @param id the id to set
	 */
	public void setId(long id) {
		this.id = id;
	}

	/**
	 * @return the version
	 */
	@JsonIgnore
	public Long getVersion() {
		return version;
	}

	/**
	 * @param version the version to set
	 */
	public void setVersion(Long version) {
		this.version = version;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	public boolean equals(Object o) {
		return (o != null && o instanceof AbstractMapObject && ((AbstractMapObject) o).getId() == id);
	}

	/**
	 * @return the created
	 */
	// @JsonIgnore
	public Date getCreated() {
		return created;
	}

	/**
	 * @param created the created to set
	 */
	public void setCreated(Date created) {
		this.created = created;
	}

	/**
	 * @return the updated
	 */
	// @JsonIgnore
	public Date getUpdated() {
		return updated;
	}

	/**
	 * @param updated the updated to set
	 */
	public void setUpdated(Date updated) {
		this.updated = updated;
	}

}
