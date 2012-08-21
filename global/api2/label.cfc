<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfcomponent output="false" extends="authentication">
	
	<!--- Set Values --->
	<cfset application.razuna.thedatabase = application.razuna.api.thedatabase>
	<cfset application.razuna.datasource = application.razuna.api.dsn>
	<cfset application.razuna.storage = application.razuna.api.storage>

	<!--- Get all labels --->
	<cffunction name="getall" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml" cachedwithin="1" region="razcache">
			SELECT /* #application.razuna.api.cachetoken["#arguments.api_key#"]#getall */ label_id, label_text, label_path
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#labels
			WHERE host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric" />
			ORDER BY label_path
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Get one labels --->
	<cffunction name="getlabel" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="label_id" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml" cachedwithin="1" region="razcache">
			SELECT /* #application.razuna.api.cachetoken["#arguments.api_key#"]#getlabel */ label_id, label_text, label_path
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#labels
			WHERE host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric" />
			AND label_id IN (<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#argument.label_id#" list="Yes">)
			ORDER BY label_path
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Add / Update label --->
	<cffunction name="setlabel" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="label_id" required="false" default="0">
		<cfargument name="label_text" required="true">
		<cfargument name="label_parent" required="false" default="0">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Set Values --->
			<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
			<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
			<cfset session.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
			<!--- Set Arguments --->
			<cfset arguments.thestruct.label_id = arguments.label_id>
			<cfset arguments.thestruct.label_text = arguments.label_text>
			<cfset arguments.thestruct.label_parent = arguments.label_parent>
			<!--- call internal method --->
			<cfinvoke component="global.cfc.labels" method="admin_update" thestruct="#arguments.thestruct#" returnVariable="lid">
			<!--- Reset cache --->
			<cfset resetcachetoken(arguments.api_key)>
			<!--- Return --->
			<cfset thexml.responsecode = 0>
			<cfset thexml.message = "Label successfully added or updated">
			<cfset thexml.label_id = lid>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Remove label --->
	<cffunction name="remove" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="label_id" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Set Values --->
			<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
			<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
			<cfset session.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
			<!--- Loop over label_id and remove them --->
			<cfloop list="#arguments.label_id#" index="i" delimiters=",">
				<!--- Call internal function --->
				<cfinvoke component="global.cfc.labels" method="admin_remove" id="#i#">
			</cfloop>
			<!--- Reset cache --->
			<cfset resetcachetoken(arguments.api_key)>
			<!--- Return --->
			<cfset thexml.responsecode = 0>
			<cfset thexml.message = "Label(s) successfully removed">
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Set asset label --->
	<cffunction name="setassetlabel" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="label_id" required="true">
		<cfargument name="asset_id" required="true">
		<cfargument name="asset_type" required="true">
		<cfargument name="append" required="false" default="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- If we replace, then remove all labels for this record first --->
			<cfif !arguments.append>
				<cfquery datasource="#application.razuna.api.dsn#">
				DELETE FROM ct_labels
				WHERE ct_id_r = <cfqueryparam value="#arguments.thestruct.asset_id#" cfsqltype="cf_sql_varchar" />
				AND ct_type = <cfqueryparam value="#arguments.thestruct.asset_type#" cfsqltype="cf_sql_varchar" />
				</cfquery>
			</cfif>
			<!--- Loop over label_id and add them --->
			<cfloop list="#arguments.label_id#" index="i" delimiters=",">
				<!--- Add to DB --->				
				<cftry>
					<cfquery datasource="#application.razuna.api.dsn#">
					INSERT INTO ct_labels
					(
						ct_label_id,
						ct_id_r,
						ct_type,
						rec_uuid
					)
					VALUES
					(
						<cfqueryparam value="#i#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.thestruct.asset_id#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.thestruct.asset_type#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#createuuid()#" CFSQLType="CF_SQL_VARCHAR">
					)
					</cfquery>
					<cfcatch type="database"></cfcatch>
				</cftry>
			</cfloop>
			<!--- Flush cache --->
			<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
			<cfinvoke component="global.cfc.extQueryCaching" method="resetcachetoken" type="labels" />
			<cfset resetcachetoken(arguments.api_key)>
			<!--- Return --->
			<cfset thexml.responsecode = 0>
			<cfset thexml.message = "Label(s) added to asset successfully">
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Remove asset label --->
	<cffunction name="removeassetlabel" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="label_id" required="true">
		<cfargument name="asset_id" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Loop over label_id and remove them --->
			<cfloop list="#arguments.label_id#" index="i" delimiters=",">
				<cfquery datasource="#application.razuna.api.dsn#">
				DELETE FROM ct_labels
				WHERE label_id = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar" />
				AND ct_id_r = <cfqueryparam value="#arguments.thestruct.asset_id#" cfsqltype="cf_sql_varchar" />
				</cfquery>
			</cfloop>
			<!--- Flush cache --->
			<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
			<cfinvoke component="global.cfc.extQueryCaching" method="resetcachetoken" type="labels" />
			<cfset resetcachetoken(arguments.api_key)>
			<!--- Return --->
			<cfset thexml.responsecode = 0>
			<cfset thexml.message = "Label(s) removed from asset successfully">
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout("s")>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- get label of asset --->
	<cffunction name="getlabelofasset" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="asset_id" required="true">
		<cfargument name="asset_type" required="true">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Query --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml" cachedwithin="1" region="razcache">
			SELECT /* #application.razuna.api.cachetoken["#arguments.api_key#"]#getlabelofasset */ l.label_id, l.label_text, l.label_path
			FROM #application.razuna.api.prefix["#arguments.api_key#"]#labels l, ct_labels ct
			WHERE ct.ct_id_r IN (<cfqueryparam value="#arguments.asset_id#" cfsqltype="cf_sql_varchar" list="Yes" />)
			AND ct.ct_type = <cfqueryparam value="#arguments.asset_type#" cfsqltype="cf_sql_varchar" />
			AND ct.ct_label_id <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "db2"><><cfelse>!=</cfif> <cfqueryparam value="" cfsqltype="cf_sql_varchar" />
			AND l.label_id = ct.ct_label_id
			AND l.host_id = <cfqueryparam value="#application.razuna.api.hostid["#arguments.api_key#"]#" cfsqltype="cf_sql_numeric" />
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- get asset from label --->
	<cffunction name="getassetoflabel" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" required="true">
		<cfargument name="label_id" required="true">
		<cfargument name="label_type" required="false" default="assets">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Set Values --->
			<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
			<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
			<cfset session.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
			<!--- Call internal function --->
			<cfinvoke component="global.cfc.labels" method="labels_assets" label_id="#arguments.label_id#" label_kind="#arguments.label_type#" fromapi="true" returnVariable="thexml">
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
</cfcomponent>