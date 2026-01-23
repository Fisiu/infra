from ansible.plugins.lookup import LookupBase
from ansible.errors import AnsibleError
import requests
import os
import time
import threading

class LookupModule(LookupBase):
    # Class-level caching for shared state across instances
    _token_cache = None
    _token_expiry = None
    _secrets_cache = {}
    _session = None
    _lock = threading.Lock()

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if LookupModule._session is None:
            LookupModule._session = requests.Session()

    def _get_token(self):
        with LookupModule._lock:
            # Check if token is cached and not expired
            if LookupModule._token_cache and LookupModule._token_expiry and time.time() < LookupModule._token_expiry:
                return LookupModule._token_cache
                
            infisical_url = os.getenv('INFISICAL_URL', 'https://app.infisical.com')
            client_id = os.getenv('INFISICAL_CLIENT_ID')
            client_secret = os.getenv('INFISICAL_CLIENT_SECRET')

            if not all([client_id, client_secret]):
                raise AnsibleError("Missing Infisical credentials: INFISICAL_CLIENT_ID and INFISICAL_CLIENT_SECRET must be set")

            try:
                auth_response = LookupModule._session.post(
                    f"{infisical_url}/api/v1/auth/universal-auth/login",
                    json={"clientId": client_id, "clientSecret": client_secret},
                    timeout=10
                )
                auth_response.raise_for_status()
                auth_data = auth_response.json()
                LookupModule._token_cache = auth_data['accessToken']
                # Refresh 5 minutes before expiry for safety
                expires_in = auth_data.get('expiresIn', 3600)
                LookupModule._token_expiry = time.time() + expires_in - 300
                return LookupModule._token_cache
            except requests.RequestException as e:
                raise AnsibleError(f"Failed to authenticate with Infisical: {e}")
            except KeyError:
                raise AnsibleError("Invalid authentication response from Infisical")

    def run(self, terms, variables=None, **kwargs):
        """
        Lookup secrets from Infisical.
        
        :param terms: List of secret names to retrieve.
        :param kwargs: Additional options, e.g., environment, path.
        :return: List of secret values.
        """
        infisical_url = os.getenv('INFISICAL_URL', 'https://app.infisical.com')
        workspace_id = os.getenv('INFISICAL_PROJECT_ID')
        environment = kwargs.get('environment', 'prod')
        secret_path = kwargs.get('path', '/')

        if not workspace_id:
            raise AnsibleError("INFISICAL_PROJECT_ID environment variable must be set")

        if not terms:
            return []

        token = self._get_token()
        results = []

        for secret_name in terms:
            if not isinstance(secret_name, str) or not secret_name.strip():
                self._display.warning(f"Skipping invalid secret name: {secret_name}")
                continue

            cache_key = f"{workspace_id}:{environment}:{secret_path}:{secret_name}"

            # Check cache
            if cache_key in LookupModule._secrets_cache:
                results.append(LookupModule._secrets_cache[cache_key])
                continue

            # Fetch from API
            try:
                response = LookupModule._session.get(
                    f"{infisical_url}/api/v3/secrets/raw/{secret_name}",
                    headers={"Authorization": f"Bearer {token}"},
                    params={
                        "workspaceId": workspace_id,
                        "environment": environment,
                        "secretPath": secret_path
                    },
                    timeout=10
                )
                response.raise_for_status()
                secret_data = response.json()
                secret_value = secret_data.get('secret', {}).get('secretValue')
                if secret_value is None:
                    raise AnsibleError(
                        f"Secret '{secret_name}' not found in environment '{environment}' "
                        f"at path '{secret_path}'"
                    )
                LookupModule._secrets_cache[cache_key] = secret_value
                results.append(secret_value)
            except requests.RequestException as e:
                status = getattr(e.response, 'status_code', 'N/A') if hasattr(e, 'response') else 'N/A'
                raise AnsibleError(
                    f"Failed to retrieve secret '{secret_name}' from '{environment}': "
                    f"HTTP {status} - {e}"
                )
            except (KeyError, ValueError) as e:
                raise AnsibleError(f"Invalid response format for secret '{secret_name}': {e}")
        
        return results

    @classmethod
    def clear_cache(cls):
        """Clear all caches (useful for testing or manual refresh)."""
        with cls._lock:
            cls._token_cache = None
            cls._token_expiry = None
            cls._secrets_cache.clear()
